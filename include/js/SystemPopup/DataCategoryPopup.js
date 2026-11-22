//数据分类编辑，新增界面的弹出层
function DataCategoryPopup(){
    //滚动条
    this.createScrollDiv=function() {
        this.scrolldiv='<div class="dvpopupsroll" style="max-height:450px;width: 100%;overflow-y:auto;margin: 0 0;diplay:inline">';
    }
}
DataCategoryPopup.type="DataCategoryPopup";
DataCategoryPopup.load=function(headtitle,Okfun,Cancelfun,cssWidth,module,OkfunParamObj,OkText,CancelfunParamObj,CancelText,searchmodule) {
     DataCategoryPopup.prototype=new CrmPopup();
     DataCategoryPopup.prototype.constructor=DataCategoryPopup;
     DataCategoryPopup.prototype.type=DataCategoryPopup.type;
     DataCategoryPopup.prototype.curmodule=module;//弹出层所在的模块

    var datacategoryobj=new DataCategoryPopup();
    datacategoryobj.setParams(headtitle,Okfun,Cancelfun,cssWidth,module,OkfunParamObj,OkText,CancelfunParamObj,CancelText);
    return datacategoryobj;
}

//一下是数据分类按钮操作事件
function DataCategoryListPopup(obj) {
    var popupobj=CrmPopup.getPopupObj("last");
    var module=popupobj.module;
    var Popupobj=new CrmPopup.load("",DataCategoryListPopup.save,"","LdPopWidth450px",module,"","","","");
    Popupobj.prevshow();
    var url="index.php?module="+module+"&action="+module+"Ajax&file=DataCategoryList";
    setListButtonColor("categorymanager");
    //zkt 20231012 XUQIU1001341 SQL注入
    ldAjaxNoProgress(url,'',function(data) {
        if(data.code==1) {
            $("status").style.display="none";
            Popupobj.createHeadHtml = function () {//wyt 230628 XUQIU1001517 PC端-模块列表界面，查询分类设置优化
                this.popupheadhtml = '<div class="E_pop_tit" id="' + this.divid + '_head">';
                this.popupheadhtml += '<strong class="E_ptita">' + data.result.title + '</strong>';
                this.popupheadhtml += '<div class="E_ptitc" style="margin: 10px 15px;" value="' + arrJsPopLabel['LBL_CLOSE'] + '" title="' + arrJsPopLabel['LBL_CLOSE'] + '" id="' + this.divid + '_imgclose"></div>';
                this.popupheadhtml += '</div>';
                this.popupheadhtml += '</div>';
            }
            // Popupobj.setHeadTitle(data.result.title);
            Popupobj.setOkText(data.result.oktext);
            Popupobj.setCancelText(data.result.canceltext);
            Popupobj.createBottomHtml = function (){
                var ok_class = '';
                var buttonpositionstyle = "";

                this.popupbottomhtml = '<div class="E_pbtn ld-bottom-color"' + buttonpositionstyle + ' id="' + this.divid + '_popupbottom"> ';
                var funname = this.Okfun.funname;
                if (funname == undefined) {
                    funname = this.Okfun.name;
                }
                this.popupbottomhtml += this.createTextBeforeSave();
                this.popupbottomhtml += '<input name="button" id="' + this.divid + '_btnok" class="ld-button ld-button-primary' + ok_class + '" value="' + this.OkText + '" tagClick="' + funname + '"  type="button">';
                this.popupbottomhtml += '<input name="button" class="ld-button ld-button-cancel" value="' + this.CancelText + '" id="' + this.divid + '_btncancel" type="button">'

                this.popupbottomhtml += ' </div>';
                this.btnokid = this.divid + "_btnok";
                this.btncancelid = this.divid + "_btncancel";
            }

            Popupobj.type="managercategory";
            Popupobj.createScrollDiv();//创建滚动条
            Popupobj.show(data.result.content);
            ld('#'+Popupobj.divid+'_scroll').css('overflow','auto').css('max-height','350px');
            Popupobj.center();

            // var cusview_obj=ld('#'+Popupobj.divid).find('div[name="draggablelist"]');
            var cusview_obj=ld('#'+Popupobj.divid).find('ul');

            ld.each(cusview_obj,function(index,obj){
                Sortable.create(obj, {
                    // group: 'stuff',
                    // animation: 150,
                    //draggable:".ld-category-draggable",
                    draggable:".ld-category-draggable",
                    //filter:".ld-category-draggable-no",
                    //handle:".drag-handle",
                    sort:true,
                    onEnd: function (evt){
                    }
                })
            })

            //32292: 单据序时簿界面：管理分类弹出层中，新建分类保存或删除分类确定后，点击“取消”按钮，结果新建、删除没有立即生效
            document.getElementById(Popupobj.btncancelid).onclick=function() {
                var url="index.php?module="+popupobj.module+"&action="+popupobj.module+"Ajax&file=ViewOrderEditSave&popup=yes&selectedColumnsString2=";
                //zkt 20231012 XUQIU1001341 SQL注入
                ldAjaxNoProgresssync(url,'',function(data) {
                    Popupobj.CancelEvent();
                    popupobj=CrmPopup.getPopupObj("last");
                    if(ld("#showCustomlist").length > 0){
                        ld("#showCustomlist").html(data.result.datacategorycontent);
                    }
                    if(ld("#showCustomlist_new").length > 0 && data.result.datacategorycontent_new){
                        ld("#showCustomlist_new").html(data.result.datacategorycontent_new);
                    }
                    //删除的数据分类要重新获取列表数据
                    //edit:can 2021-01-07 43620: （https://61mis.com/kfbcrm [^]）首页，销售简报，点击“新建客户、新建销售机会个数”等报表，在新打开的链接单据列表界面点击【管理分类】-【取消】后，界面弹出查看范围-高级弹出层
                    showDefaultCustomView(new Object,popupobj.module,'',ld("#selectcustomview_"+popupobj.module).val());
                })
            }
            return Popupobj;
        }
        else {
            RemindsMsg("","LdPopWidth400px","","yes","yes",data.msg);
        }
    });
}
//编辑新增复制的数据分类字段拖动排序 2023-7-12 xxy XUQIU1001609 PC端-数据分类，选择显示字段优化（需求）
DataCategoryListPopup.ProductDetaildrag = function (){
    var popupobj=CrmPopup.getPopupObj("last");
	ld('#'+popupobj.divid+" table[class='settingPopTable lasttdbordernon']").find("div[name='selectedAssmablyColumns'],div[name='AssmablyList']").children().hover(function() {
		ld('#'+popupobj.divid+' .ld-dragicon').hide();
		ld(this).find('.ld-dragicon').show();
	});
    ld('#'+popupobj.divid+" table[class='settingPopTable lasttdbordernon']").find("div[name='selectedAssmablyColumns'],div[name='AssmablyList']").children().mouseleave(function(){
        ld(this).find('.ld-dragicon').hide();
    });
	if(ld('#'+popupobj.divid+" table[class='settingPopTable lasttdbordernon']").find("div[name='selectedAssmablyColumns']").children().length > 0) {
		Sortable.create(ld('#'+popupobj.divid+" table[class='settingPopTable lasttdbordernon']").find("div[name='selectedAssmablyColumns']").get(0), {
			group: 'fieldlayout',
			draggable: ".ld-category-draggable",
			handle: ".drag-handle",
			animation: 150,
			sort: true,
			onEnd: function (evt) {
                if (evt.from != evt.to) { //移动至另一个容器时才改变data-tip
                    ld(evt.item).find('a.ld-dragicon').attr('data-tip',arrJsPopLabel['MoveRightToDisplay']);
                }
			}
		});
        Sortable.create(ld('#'+popupobj.divid+" table[class='settingPopTable lasttdbordernon']").find("div[name='AssmablyList']").get(0), {
            group: 'fieldlayout',
            draggable: ".ld-category-draggable",
            handle: ".drag-handle",
            animation: 150,
            sort: false,
            onEnd: function (evt) {
                if (evt.from != evt.to) { //移动至另一个容器时才改变data-tip
                    ld(evt.item).find('a.ld-dragicon').attr('data-tip',arrJsPopLabel['DRAGTOSORT'])
                }
            }
        });
	}
}
//多选字段 XUQIU1001802 序时簿列表--查询分类--增加多选、多选上下移动
DataCategoryListPopup.MultipleSelectionFields = function () {
    ld('#'+popupobj.divid+' .commonSelect').off('mousedown mouseover mouseup');//先去除绑定事件
    
    ld(document).ready(function () {
        var isMouseDown = false;
        var isSelecting = false;
        
        ld('#'+popupobj.divid+' .commonSelect').mousedown(function (event) {
            if(ld(event.target).hasClass('drag-handle')){
                return;
            }
            else if(ld(event.target).is('input')){
                return;
            }
            isMouseDown = true;
            
            // 获取当前行关联的input元素
            const ldinput = ld(this).find('input:first');
            
            // 切换当前行的选中状态
            isSelecting = !ldinput.prop('checked');
            ldinput.prop('checked', isSelecting);
    
            // 阻止默认行为但允许事件继续传播
            event.preventDefault();
        }).mouseover(function () {
            if (isMouseDown) {
                // 获取当前行关联的input元素
                const ldinput = ld(this).find('input:first');
                // 设置当前行的选中状态
                ldinput.prop('checked', isSelecting);
            }
        }).bind("selectstart", function () {
            return false; // prevent text selection in IE
        });
    
        ld(document).mouseup(function () {
            isMouseDown = false;
        });
    
        // 独立处理label的点击事件
        ld('#'+popupobj.divid+' .commonSelect label').unbind('click').click(function (event) {
            const ldassociatedInput = ld(this).siblings('input:first');
            ldassociatedInput.prop('checked', !ldassociatedInput.prop('checked'));
        });
    });
};
//提示：请将左侧字段移至此处
DataCategoryListPopup.movetips=function(mutationsList, observer) {
    for(var mutation of mutationsList) {
        if (mutation.type === 'childList' && ld(mutation.target).children().length === 1) {
            ld(mutation.target).find(" span#movetips").show();
            ld(mutation.target).css('display','flex');
            ld(mutation.target).css('justify-content','center');
        }
        else{
            ld(mutation.target).find(" span#movetips").hide();
            ld(mutation.target).css('display','block');
        }
    }
}
//编辑新增复制的数据分类保存
DataCategoryListPopup.pageoperation=function() {
    var popupobj=CrmPopup.getPopupObj("last");
    var module=popupobj.module;
    var url='index.php?module='+module+"&action="+module+"Ajax"+"&file=CustomView&popup=yes";
    if(DataCategoryListPopup.groupid > 0) {
        url+="&groupid="+DataCategoryListPopup.groupid;
    }
    if(DataCategoryListPopup.pagemode=='edit') {
        url+="&viewedit=true&record="+DataCategoryListPopup.pagerecord;
    }
    else if(DataCategoryListPopup.pagemode=='copy') {
        url+="&viewcopy=true&record="+DataCategoryListPopup.pagerecord;
    }
    
    //zkt 20231012 XUQIU1001341 SQL注入
    ldAjaxNoProgresssync(url,'',function(data) {
        if(data.code==1) {
            DataCategoryPopupobj=DataCategoryPopup.load(data.result.title,DataCategoryListPopup.pagesave,"","LdPopWidth800px",module,"",data.result.oktext,"",data.result.canceltext);
            DataCategoryPopupobj.createScrollDiv();//创建滚动条

            DataCategoryPopupobj.show(data.result.content);
            var cls_resetComboxHtmlobj=new cls_resetComboxHtml("groupSelectPop");
            cls_resetComboxHtmlobj.setComboxObjHtml();
            cls_resetComboxHtmlobj.setComboxObjHtmlByWidth(190);

            DataCategoryPopupobj.showvalues=data.result.showvalues;
            DataCategoryPopupobj.datetimestr=data.result.datetimestr;//基本查询
            DataCategoryPopupobj.viewnamelabel=data.result.viewnamelabel;
            DataCategoryPopupobj.fields=JSON.parse(data.result.fields);//231207 wym BUG0076816 “查询分类”-“新建分类”-“设置条件”处，选择“团队成员”字段后，右侧条件下拉框内，不显示“包含当前操作员”

            var advancefilterobj = new cls_advanceFilter();
            var params = {};
            params.columnOptionHtml = data.result.columns_block;
            params.fLabels = data.result.flabels;
            params.datetimestr = data.result.datetimestr;
            params.advfilterhtml = data.result.foption;
            params.mandatorycheck = data.result.mandatorycheck;
            params.fieldsinfo = JSON.parse(data.result.fields);
            params.criteria_groups_arr = data.result.criteria_groups;
            params.module = module;
            params.divid = 'adv_filter_div';
            // edit: xll 2024/11/8  XUQIU1001239  高级查找部分字段优化
            params.advanceFields = data.result.advanceFields;
            advancefilterobj.showAdvanceFilter(DataCategoryPopupobj,params);

            if(data.result.record == ''&& data.result.viewCopy=="NoCopy"&&data.result.mandatorycheck!=null) {
                for(k=0;k<data.result.mandatorycheck.length;k++) {
                    selname = "column"+(k+1);
                    selelement = CrmPopup.findHtmlobj(DataCategoryPopupobj.divid,selname);
                    if(selelement == null || typeof selelement == 'undefined') continue;
                    colOpts = selelement.options;
                    selelement.find("label").each(function(){
                        if(ld(this).attr("value")== data.result.mandatorycheck[k]) {
                            ld(this).find("input").prop("checked", true);
                            return false;
                        }
                    })
                }
            }
            DataCategoryListPopup.ProductDetaildrag();
            DataCategoryListPopup.MultipleSelectionFields();
            tooltip('.sort-tip-items', {transition: true, time: 200});
            standardFilterDisplay();
            var targetNode = ld('#'+DataCategoryPopupobj.divid+" div[name='selectedAssmablyColumns']")[0];
            if(targetNode && !empty(targetNode)){
                var config = { childList: true };
                var observer = new MutationObserver(DataCategoryListPopup.movetips);
                observer.observe(targetNode, config);
                //wym XUQIU1001870 查询分类 排序方式变为可搜索下拉框
                var sortorder_trobj=CrmPopup.findHtmlobj(DataCategoryPopupobj.divid,'sortorder_tr');
                if(sortorder_trobj!=undefined){
                    ld.each(sortorder_trobj,function(){
                        var rowindex = ld(this).attr('rowindex');
                        if(ld('#'+DataCategoryPopupobj.divid+" #sortselect"+rowindex)){
                            var selectobj=ld('#'+DataCategoryPopupobj.divid+" #sortselect"+rowindex);
                            var selectname = selectobj.attr('name');
                            var cls_resetComboxHtmlobj=new cls_resetComboxHtml(selectname);
                            cls_resetComboxHtmlobj.setSearchComboxWidthByhtml(selectobj,190);
                        }
                        //wym BUG0074494 第一条排序删除不显示,后续显示
                        if(rowindex!=0&&ld('#'+DataCategoryPopupobj.divid+" #sortdelete"+rowindex)){
                            ld('#'+DataCategoryPopupobj.divid+" #sortdelete"+rowindex).css('display','');
                        }
                    });
                }
            }
            DataCategoryPopupobj.center();
        }
        else {
            RemindsMsg("","LdPopWidth400px","","yes","yes",data.msg);
        }
    });
}
//保存数据分类
DataCategoryListPopup.pagesave=function() {
    if(DataCategoryListPopup.productmandatoryCheck_2()){
        DataCategoryListPopup.validateCV();
    }
}
DataCategoryListPopup.pagesave.funname="DataCategoryListPopup.pagesave";

//新增数据分类
DataCategoryListPopup.add=function() {
    //setListButtonColor("createCategory");
    DataCategoryListPopup.pagemode='create';
    DataCategoryListPopup.pageoperation();
}
DataCategoryListPopup.Copy=function(obj,record) {
    DataCategoryListPopup.pagemode='copy';
    DataCategoryListPopup.pagerecord=record;
    DataCategoryListPopup.groupid = 0;
    DataCategoryListPopup.pageoperation();
}
//编辑数据分类
DataCategoryListPopup.Edit=function(obj,record) {
    DataCategoryListPopup.pagemode='edit';
    DataCategoryListPopup.pagerecord=record;
    DataCategoryListPopup.groupid = 0;
    DataCategoryListPopup.pageoperation();
}
//@edit zsk 2024/06/11 XUQIU20240516-01 查询分类功能优化-收藏数据分类
DataCategoryListPopup.addToCommon=function(obj,record){
    var popupobj = CrmPopup.getPopupObj("last");
    var module = popupobj.module;
    if(ld(obj).find('b').hasClass('ld-category-deleteFromCommon')){
        ld(obj).find('b').removeClass('ld-category-deleteFromCommon')
        ld(obj).find('b').addClass('ld-category-addToCommon')
        var url = "index.php?module=" + module + "&action=" + module + "Ajax&file=ViewOrderEditSave&deleteFromCommon=" + record;
        ldAjax(url, '', function (res) {
            if (res.code == 1) {
                DelProgressObjs()
                //刷新查询分类弹出框
                getJsScript('include/js/CustomViewGroupRightSetting.js', function () {
                    CustomViewGroupRightSettingobj = new CustomViewGroupRightSetting();
                    CustomViewGroupRightSettingobj.custom_info = module;
                    CustomViewGroupRightSettingobj.reloadCustomViewPopupGroupList();
                })
            }
        })
    }
    else {
        ld(obj).find('b').removeClass('ld-category-addToCommon')
        ld(obj).find('b').addClass('ld-category-deleteFromCommon')
        var url = "index.php?module=" + module + "&action=" + module + "Ajax&file=ViewOrderEditSave&addToCommon=" + record;
        ldAjax(url, '', function (res) {
            if (res.code == 1) {
                DelProgressObjs()
                //刷新查询分类弹出框
                getJsScript('include/js/CustomViewGroupRightSetting.js', function () {
                    CustomViewGroupRightSettingobj = new CustomViewGroupRightSetting();
                    CustomViewGroupRightSettingobj.custom_info = module;
                    CustomViewGroupRightSettingobj.reloadCustomViewPopupGroupList();
                })
            }
        })
    }
}
DataCategoryListPopup.changeTrColor=function(trobj) {
    var trlength=(trobj.parent().find("tr").length);
    var i=0;
    trobj.parent().find("tr").each(function(){
        ld(this).find("td").each(function(){
            if(i%2!=0) {
                ld(this).css("background-color","#fff");
            }
            else {
                ld(this).css("background-color","#f8f8f8");
            }
        })
        i++;
    })
}
DataCategoryListPopup.showhidearrow=function(trobj) {
    DataCategoryListPopup.changeTrColor(trobj);
    var trlength=(trobj.parent().find("tr").length);
    var i=0;
    if(trlength<=4) {
        trobj.find(".datacategory_up").css("display",'none');
        trobj.find(".datacategory_down").css("display",'none');
        return ;
    }
    if(trobj.index()==1) {
        return ;
    }
    //第一行，隐藏向上的箭头
    if(trobj.index()==2){
        trobj.find(".datacategory_up").css("display",'none');
        trobj.find(".datacategory_down").css("display",'');
    }
    //最后一行隐藏乡下的箭头
    if(trobj.index()==trlength-2) {
        trobj.find(".datacategory_down").css("display",'none');
        trobj.find(".datacategory_up").css("display",'');
    }
    if(trobj.index()!=trlength-2&&trobj.index()!=2&&trobj.index()!=trlength-1) {
        trobj.find(".datacategory_up").css("display",'');
        trobj.find(".datacategory_down").css("display",'');
    }
}
//保存排序
DataCategoryListPopup.sortorder=function() {
    var popupobj=CrmPopup.getPopupObj("last");
    var selectedColumnsString2="";
    ld("#"+popupobj.divid+" .customviewlisttable").find('li').each(function(){
        if(ld(this).attr("tag")!=undefined){
            selectedColumnsString2+=ld(this).attr("tag")+";";
        }
    })
    selectedColumnsString2=selectedColumnsString2.substr(0, selectedColumnsString2.length - 1); ;
    var url="index.php?module="+popupobj.module+"&action="+popupobj.module+"Ajax&file=ViewOrderEditSave&popup=yes&selectedColumnsString2="+selectedColumnsString2;
    //zkt 20231012 XUQIU1001341 SQL注入
    ldAjaxNoProgresssync(url,'',function(data) {
        if(data.code==1) {
            popupobj.CancelEvent();
            popupobj=CrmPopup.getPopupObj("last");

            if(ld("#showCustomlist").length > 0){
                ld("#showCustomlist").html(data.result.datacategorycontent);
            }
            if(ld("#showCustomlist_new").length > 0 && data.result.datacategorycontent_new){
                ld("#showCustomlist_new").html(data.result.datacategorycontent_new);
            }
            //删除的数据分类要重新获取列表数据
            //SmOwnerSearchSeniorBtnOk
            var searchscope = encodeURIComponent(document.getElementById("SmOwnerSearchScope").options[document.getElementById("SmOwnerSearchScope").options.selectedIndex].value);
            if('smowner_search_senior' == searchscope){
                getJsScript('include/js/ScopePopup/ScopePopup_Details.js',function(){
                    var senioruserid = '';
                    if(ld('#scope_senioruserids') != undefined){
                        senioruserid = ld('#scope_senioruserids').val();
                    }
                    ScopePopup_Details.getInstance().SmOwnerSearchSeniorBtnOk(module,searchscope,'','listview');
                });
            }
            else{
                SmOwnerSearchScopeChange(document.getElementById("SmOwnerSearchScope"),popupobj.module,'');
            }
        }
        else{
            RemindsMsg("","LdPopWidth400px","","yes","yes",data.msg);
        }
    });
}
DataCategoryListPopup.save=function() {
    DataCategoryListPopup.sortorder();
}
DataCategoryListPopup.save.funname="DataCategoryListPopup_save";
DataCategoryListPopup.delVal=function(obj,record) {
    var confirm_str = arrJsPopLabel['SUREWANTDELETE'];
    RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
    //确定按钮
    ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
        var popupobj=CrmPopup.getPopupObj("last");
        var module=popupobj.module;
        var url="index.php?module=CustomView&action=CustomViewAjax&file=Delete&dmodule="+module+"&refreshpage=no&smodule="+module+"&record="+record;
        //zkt 20231012 XUQIU1001341 SQL注入
        ldAjaxNoProgress(url,'',function(data) {
            if(data.code==1) {
                var curtr_obj=ld("#"+popupobj.divid+" [tag="+record+"_del]").closest("li");
                curtr_obj.remove();
                // 根据弹出中是否有分类对象判断，"消息"模块目前只有分类没有分组
                if(popupobj.CustomViewCategoryRightSettingobj && !empty(popupobj.CustomViewCategoryRightSettingobj)){
                    popupobj.CustomViewCategoryRightSettingobj.reloadCustomViewPopup();
                    ld('#ld-listview-group-right-setting-drawer').find('li.listview_customview_drawer_content_list_li[data-cvid='+record+']').remove();
                }
                else{
                    if(CustomViewGroupRightSettingobj != undefined){
                        CustomViewGroupRightSettingobj.reloadCustomViewPopup();
                        ld('#ld-listview-group-right-setting-drawer').find('li.listview_customview_drawer_content_list_li[data-cvid='+record+']').remove();
                    }
                }
            }
            else {
                RemindsMsg("","LdPopWidth400px","","yes","yes",data.msg);
            }
        });
    });
}

var groupeamil_name="";
DataCategoryListPopup.productmandatoryCheck=function() {
    var popupobj=CrmPopup.getPopupObj("last");
    var mandatorycheck = false;
    var i,j;
    var manCheck =popupobj.advanceFilterObj.mandatorycheck;
    var showvalues = popupobj.showvalues;
    var module =popupobj.module;
    var sortArray = new Array();
    var sortOrder = new Array();
    var key = 0;
    var isError = false;
    var errorMessage = "";
    var productinfo = "";

    var selObj=CrmPopup.findHtmlobj(popupobj.divid,'selectedAssmablyColumns');
    var sortorderlist = "";
    if (trim(CrmPopup.findHtmlobj(popupobj.divid,'viewName').val()) == "") {
        isError = true;
    }
    if (isError == true) {
        var confirm_str = arrJsPopLabel['CATEGORYNAMECANOTEMPTY'];
        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
        return false;
    }

    //判断显示列大于三列
    if(selObj.find("option").length< 3) {
        var confirm_str = arrJsPopLabel['COLUMNSELECTLEASTTHREE'];
        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
        return false;
    }

    selObj.find("option").each(function(){
         productinfo+=ld(this).val()+","
    });

    CrmPopup.findHtmlobj(popupobj.divid,'ProductListView').val(productinfo) ;
    if(CrmPopup.isExistsObj(popupobj.divid,'more_listview') && CrmPopup.findHtmlobj(popupobj.divid,'more_listview').val() == 0) {
        for(i=1;i<=9;i++) {
            var columnvalue = CrmPopup.findHtmlobj(popupobj.divid,"column"+i).val();
            if(columnvalue != null) {
                for(j=0;j<manCheck.length;j++) {
                    if(columnvalue == manCheck[j]) {
                        mandatorycheck = true;
                    }
                }
                if(mandatorycheck == true) {
                    if((ld("jscal_field_date_start").value.replace(/^\s+/g, '').replace(/\s+$/g, '').length!=0) || ($("jscal_field_date_end").value.replace(/^\s+/g, '').replace(/\s+$/g, '').length!=0)){
                        return stdfilterdateValidate();
                    }
                    else{
                        return true;
                    }
                }
                else {
                    mandatorycheck = false;
                }
            }
        }
    }

    //获取已选择的分类名称
    var k=0;
    if(CrmPopup.isExistsObj(popupobj.divid,'sortselect'+k)) {
        sortArray[key] =CrmPopup.findHtmlobj(popupobj.divid,'sortselect'+k).val();
        var SortOrderRadio=ld("#"+popupobj.divid+"  input[name='sortorder0']");
        SortOrderRadio.each(function(){
             if(ld(this).prop("checked")) {
                CrmPopup.findHtmlobj(popupobj.divid,'SortOrderList').val(CrmPopup.findHtmlobj(popupobj.divid,'sortselect'+k).val() +"|"+ld(this).val());
                sortOrder[key] = CrmPopup.findHtmlobj(popupobj.divid,'sortselect'+k).val() +"|"+ld(this).val();
             }
        })
    }
    return true;
}
//2023-7-11 xxy 选择的option全换成checkbox和label XUQIU1001609 PC端-数据分类，选择显示字段优化（需求）
DataCategoryListPopup.productmandatoryCheck_2=function()
{
    var popupobj=CrmPopup.getPopupObj("last");
    var mandatorycheck = false;
    var i,j;
    var manCheck =popupobj.advanceFilterObj.mandatorycheck;
    var showvalues = popupobj.showvalues;
    var module =popupobj.module;
    var sortArray = new Array();
    var sortOrder = new Array();
    var key = 0;
    var isError = false;
    var errorMessage = "";
    var productinfo = "";
    var sortorderlist = "";
    if (trim(CrmPopup.findHtmlobj(popupobj.divid,'viewName').val()) == "") {
        isError = true;
    }
    if (isError == true) {
        var confirm_str = arrJsPopLabel['CATEGORYNAMECANOTEMPTY'];
        MessagePopup.TipZero_warning(confirm_str);
        return false;
    }
    var selObj=CrmPopup.findHtmlobj(popupobj.divid,'selectedAssmablyColumns');
    if(selObj && selObj.length > 0){
        selObj = selObj.children();
        //判断显示列大于三列
        if(selObj.length< 3) {
            var confirm_str = arrJsPopLabel['COLUMNSELECTLEASTTHREE'];
            MessagePopup.TipOne_warning(confirm_str);
            return false;
        }
        selObj.find("label").each(function(){
            productinfo+=ld(this).attr("value")+","
        });
        CrmPopup.findHtmlobj(popupobj.divid,'ProductListView').val(productinfo);
    }
    if(CrmPopup.isExistsObj(popupobj.divid,'more_listview') && CrmPopup.findHtmlobj(popupobj.divid,'more_listview').val() == 0) {
        for(i=1;i<=9;i++) {
            var columnvalue = CrmPopup.findHtmlobj(popupobj.divid,"column"+i).val();
            if(columnvalue != null) {
                for(j=0;j<manCheck.length;j++) {
                    if(columnvalue == manCheck[j]) {
                        mandatorycheck = true;
                    }
                }
                if(mandatorycheck == true) {
                    if((ld("jscal_field_date_start").value.replace(/^\s+/g, '').replace(/\s+$/g, '').length!=0) || ($("jscal_field_date_end").value.replace(/^\s+/g, '').replace(/\s+$/g, '').length!=0)){
                        return stdfilterdateValidate();
                    }
                    else{
                        return true;
                    }
                }
                else {
                    mandatorycheck = false;
                }
            }
        }
    }

    //wym XUQIU1001870 获取已选择的分类名称
    var sortorder_trobj=CrmPopup.findHtmlobj(popupobj.divid,'sortorder_tr');
    if(sortorder_trobj!=undefined){
        var maxindex=sortorder_trobj.eq(-1).attr('rowindex');
        for(var k=0;k<=maxindex; k++) {
            if(CrmPopup.isExistsObj(popupobj.divid,'sortselect'+k)) {
                sortArray[key] = CrmPopup.findHtmlobj(popupobj.divid,'sortselect'+k).val();
                var SortOrderRadio=ld("#"+popupobj.divid+"  input[name='sortorder"+k+"']");
                SortOrderRadio.each(function(){
                    if(ld(this).prop("checked")) {
                        //wym BUG0074171
                       sortOrder[key] = CrmPopup.findHtmlobj(popupobj.divid,'sortselect'+k).val() +"|"+ld(this).val();
                    }
                })
                key++;
            }
        }
        popupobj.sortOrder=sortOrder;
    }
    return true;
}
DataCategoryListPopup.validateCV=function() {
    var popupobj=CrmPopup.getPopupObj("last");
    if(getObj('group').value!='') {
        if(popupobj.advanceFilterObj.checkAdvancedFilter()==false) {
            return false;
        }
    }
    else{
        if(DataCategoryListPopup.checkDuplicate()) {
            if( popupobj.advanceFilterObj.checkAdvancedFilter()==false) {
                return false;
            }
	    }
        else {
            return false;
        }
    }
	DataCategoryListPopup.checkViewNameDup();
	return false;
}

//edit:can reason:判断视图名称是否重复,bug:10932: 客户中创建分类异常
DataCategoryListPopup.checkViewNameDup=function()
{
    var popupobj=CrmPopup.getPopupObj("last");
    var record=CrmPopup.findHtmlobj(popupobj.divid,'record').val();
    if(groupeamil_name=='MassSMS' || groupeamil_name=='Emails'){
       var module = groupeamil_name;
    }
    else{
        var module=popupobj.module;
    }
    var viewname=CrmPopup.findHtmlobj(popupobj.divid,'viewName').val();
    var urlstring="module=CustomView&action=CustomViewAjax&file=ProductSave&record="+record+"&cvmodule="+module+"&viewName="+encodeURIComponent(viewname)+"&repeat=1&ReportHeader=dheader";
    if(CrmPopup.findHtmlobj(popupobj.divid,'setDefault').prop("checked")){
        urlstring+='&setDefault=1';
    }
    if(CrmPopup.findHtmlobj(popupobj.divid,'setMetrics').prop("checked")){
        urlstring+='&setMetrics=1';
    }
    //@edit:zsk @date:2024/06/11 @reason:XUQIU20240516-01 查询分类功能优化
    if(CrmPopup.findHtmlobj(popupobj.divid,'setAsMyCommon').length > 0){
        if(CrmPopup.findHtmlobj(popupobj.divid,'setAsMyCommon').prop("checked")){
            urlstring+='&setAsMyCommon=yes';
        }else{
            urlstring+='&setAsMyCommon=no';
        }
    }
    if((CrmPopup.findHtmlobj(popupobj.divid,"groupSelectPop").val())!='ungrouped'){
        urlstring+="&customViewGroup="+CrmPopup.findHtmlobj(popupobj.divid,"groupSelectPop").val();
    }
    // @edit:dong @date:2020/11/05 @reason: 设置为自定义链接模块
    if(CrmPopup.findHtmlobj(popupobj.divid,'setaslinkmodule').prop("checked")){
        urlstring+='&setaslinkmodule=1';
    }
    else{
        urlstring+='&setaslinkmodule=0';
    }
    if(CrmPopup.findHtmlobj(popupobj.divid,'setStatus').prop("checked")){
        urlstring+='&setStatus=3';
    }
    urlstring+="&advft_criteria_groups="+popupobj.advanceFilterObj.advft_criteria_groups;
    urlstring+="&advft_criteria="+popupobj.advanceFilterObj.advft_criteria;
    urlstring+="&ProductListView="+CrmPopup.findHtmlobj(popupobj.divid,"ProductListView").val();
    //wym BUG0074171
    urlstring+="&SortOrderList="+JSON.stringify(popupobj.sortOrder);
    urlstring+="&stdDateFilterField="+CrmPopup.findHtmlobj(popupobj.divid,'stdDateFilterField').val();
    urlstring+="&stdDateFilter="+CrmPopup.findHtmlobj(popupobj.divid,'stdDateFilter').val();
    urlstring+="&startdate="+CrmPopup.findHtmlobj(popupobj.divid,'startdate').val();
    urlstring+="&enddate="+CrmPopup.findHtmlobj(popupobj.divid,'enddate').val();
    urlstring+="&refreshpage=no";
    //复制数据分类
    if(DataCategoryListPopup.pagemode=='copy'){
        urlstring+="&viewcopy=true&viewcopy_cvid="+DataCategoryListPopup.pagerecord;
    }
    //zkt 20231010  XUQIU1001341 SQL注入
    ldAjax("index.php?"+urlstring,'',function(data) {
        DelProgressObjs();
        if(data.code==-1) {
            $("status").style.display="none";
            var confirm_str = popupobj.viewnamelabel+arrJsPopLabel['CANOTREPEATED'];
            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
        }
        else{
            popupobj.CancelEvent();
            popupobj=CrmPopup.getPopupObj("last");//获取数据分类列表弹出层
            var customviewobj = ld('#'+popupobj.divid+' #showCustomlist_new');
            if(customviewobj && customviewobj.length > 0){
                customviewobj.removeClass('activate')
                document.removeEventListener('click', cancelCvPopup);
            }
            if(popupobj.type=="managercategory") {
               var viewname=data.result.viewname;
               var cvid=data.result.cvid;

               if(DataCategoryListPopup.pagemode=='create'||DataCategoryListPopup.pagemode=='copy') {
                   var trlastobj=ld("#"+popupobj.divid+" .customviewlisttable").find("li:last");
                   var strhtml='<li class="ld-category-l ld-category-draggable" tag="'+cvid+'"><div class="ld-category-name">'+viewname+'</div>';
                   strhtml+='<div class="ld-category-operate">';
                   strhtml+='<a onclick="DataCategoryListPopup.Edit(this,'+cvid+')" title="'+data.result.edittext+'" style="margin-right:8px;cursor: pointer;"><b class="ld-category-icon ld-category-edit"></b></a>';
                   strhtml+='<a onclick="DataCategoryListPopup.Copy(this,'+cvid+')" title="'+data.result.copytext+'" style="margin-right:8px;cursor: pointer;"><b class="ld-category-icon ld-category-copy"></b></a>';
                   strhtml+='<a class="ld-category-icon ld-category-del" style="cursor: pointer;" tag="'+cvid+'_del" onclick="DataCategoryListPopup.delVal(this,'+cvid+');" title="'+data.result.deletetext+'"></a>';
                   strhtml+='<a class="ld-category-icon ld-category-drag drag-handle" style="cursor: pointer;"  ></a>';
                   strhtml+='</div></li>';

                   //新增和复制添加一行
                   trlastobj.after(strhtml)

                   ld("#"+popupobj.divid+"_scroll").scrollTop(document.getElementById(popupobj.divid+"_scroll").scrollHeight+10);
                   DataCategoryListPopup.changeTrColor(trlastobj);
               }
               else {
                   //编辑，修改分类名称
                   // ld("#"+popupobj.divid+" .customviewlisttable").find("tr[tag="+cvid+"]").find("td:eq(0)").html(viewname);
                   ld("#"+popupobj.divid+" .customviewlisttable").find("li[tag="+cvid+"]").find(".ld-category-name").html(viewname);
               }
            }
            else {
                //hzx 20240428 保存查询分类后刷新列表
                if(popupobj.pagetype && (popupobj.pagetype == 'listpage' || popupobj.pagetype == 'calendarview')){
                    showDefaultCustomView(new Object,popupobj.module,'',ld("#"+popupobj.divid+" #viewname").val());
                    if(ld('#ld-listview-group-right-setting-drawer').length > 0 &&  typeof CustomViewGroupRightSettingobj != "undefined" && CustomViewGroupRightSettingobj != undefined){
                        if(data.result.groupList && data.result.groupList.groupList){
                            var groupListObj=data.result.groupList.groupList;
                            groupListObj = groupListObj.reduce((acc, curr, index) => {
                               acc[index] = curr;
                               return acc;
                            }, {});
                            CustomViewGroupRightSettingobj.groupList=groupListObj;
                            CustomViewGroupRightSettingobj.Show_Listview_group_drawer_content();
                        }
                    }
                }
                // 根据弹出中是否有分类对象判断，"消息"模块目前只有分类没有分组
                else if(popupobj.CustomViewCategoryRightSettingobj && !empty(popupobj.CustomViewCategoryRightSettingobj)){
                    if(ld('#ld-listview-group-right-setting-drawer').length > 0){
                        if(data.result.groupList && data.result.groupList.groupList){
                            var groupListObj=data.result.groupList.groupList;
                            groupListObj = groupListObj.reduce((acc, curr, index) => {
                                acc[index] = curr;
                                return acc;
                            }, {});
                            popupobj.CustomViewCategoryRightSettingobj.groupList=groupListObj;
                            popupobj.CustomViewCategoryRightSettingobj.Show_Listview_group_drawer_content();
                        }
                    }
                }
                else{
                    if(DataCategoryListPopup.pagemode=='create') {
                        ld("#showCustomlist").html(data.result.datacategorycontent);
                    }
                }
            }
            DataCategoryListPopup.afterSaveEvent(data);
        }
    });
}
DataCategoryListPopup.checkDuplicate=function() {
    var popupobj=CrmPopup.getPopupObj("last");
    if(CrmPopup.isExistsObj(popupobj.divid,'more_listview')&&CrmPopup.findHtmlobj(popupobj.divid,'more_listview').val() == 1) {
        return true;
    }
	if(CrmPopup.findHtmlobj(popupobj.divid,'viewName').val().toLowerCase() == 'all') {
		var confirm_str = arrJsPopLabel['CANOTUSERNAMEOFALL'];
        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
		return false;
	}
	return true;
}

//wym XUQIU1001870 新增查询分类排序方式
DataCategoryListPopup.addCustomorder=function(obj){
    var popupobj=CrmPopup.getPopupObj("last");
    var sortorder_trobj=CrmPopup.findHtmlobj(popupobj.divid,'sortorder_tr');
    if(sortorder_trobj.length>=10){
        MessagePopup.TipZero_warning(arrJsPopLabel["UPTOTENSORTORDER"]);
        return false;
    }
    var minindex=sortorder_trobj.eq(0).attr('rowindex');
    var maxindex=sortorder_trobj.eq(-1).attr('rowindex');
    if(maxindex==NaN||maxindex==''||maxindex==undefined){ //没有行时从0计数，有行时在前一行上+1
        maxindex = 0;
    }
    else{
        maxindex++;
    }
    var content_html='';
    content_html ='<tr id="sortorder_tr'+maxindex+'" name="sortorder_tr" rowindex="'+maxindex+'">' +
        '<td width="5%" style="padding-left:10px;">'+arrJsPopLabel["SORTORDER"]+'&nbsp;'+
        '</td>' +
        '<td>' +
        '<select class="commonSelectPop" name="sortselect'+maxindex+'" id="sortselect'+maxindex+'">' +
        '</select>' +
        '</td>' +
        '<td colspan="2">' +
        '<div id="sortdiv'+maxindex+'">'+
        '<input type="radio" style="margin-top: -3px;" id="sortorderasc'+maxindex+'" name="sortorder'+maxindex+'" checked value="asc"/><label for="sortorderasc'+maxindex+'"> '+arrJsPopLabel["ASCENDINGORDER"]+'&nbsp;&nbsp;</label>\n'+
        '<input type="radio" style="margin-top: -3px;" id="sortorderdesc'+maxindex+'" name="sortorder'+maxindex+'" value="desc"/><label for="sortorderdesc'+maxindex+'"> '+arrJsPopLabel["DESCENDINGORDER"]+'&nbsp;&nbsp;</label>\n'+
        '<a title="'+arrJsPopLabel["DELETE"]+'" onclick="DataCategoryListPopup.deleteCustomorder('+maxindex+')">'+arrJsPopLabel["DELETE"]+'</a>' +
        '</div>' +
        '</td>' +
        '</tr>';
    var trobj=Tools.getParentobjByChild(ld(obj),'tr');
    trobj.before(content_html);
    var sourceSelect=ld("#"+popupobj.divid+" #sortselect"+minindex);
    var targetSelect=ld("#"+popupobj.divid+" #sortselect"+maxindex);
    sourceSelect.find('option').clone().appendTo(targetSelect);
    var cls_resetComboxHtmlobj=new cls_resetComboxHtml("sortselect"+maxindex);
    cls_resetComboxHtmlobj.setSearchComboxWidthByhtml(targetSelect,180);
}
//wym XUQIU1001870 删除查询分类排序方式
DataCategoryListPopup.deleteCustomorder=function(id){
    var popupobj=CrmPopup.getPopupObj("last");
    var sortorder_trobj=CrmPopup.findHtmlobj(popupobj.divid,'sortorder_tr');
    if(sortorder_trobj.length==1){
        MessagePopup.TipZero_warning(arrJsPopLabel["SELECTONESORTORDER"]);
    }
    else{
        ld("#"+popupobj.divid+" #sortorder_tr"+id).remove();
    }
}
// 保存分类后事件
DataCategoryListPopup.afterSaveEvent = function(data){
}

function stdfilterdateValidate() {
	if(!dateValidate("startdate",arrJsPopLabel['STANDARDRULES']+" - "+arrJsPopLabel['STARTDATE'],"OTH")) {
		getObj("startdate").focus()
		return false;
	}
	else if(!dateValidate("enddate",arrJsPopLabel['STANDARDRULES']+" - "+arrJsPopLabel['ENDDATE'],"OTH")) {
		getObj("enddate").focus()
		return false;
	}
	else {
        if (!dateComparison("enddate",arrJsPopLabel['STANDARDRULES']+" - "+arrJsPopLabel['ENDDATE'],"startdate",arrJsPopLabel['STANDARDRULES']+" - "+arrJsPopLabel['STARTDATE'],"GE")) {
            getObj("enddate").focus()
            return false;
        }
        else{
            return true;
        }
	}
}

/**
* @edit:dong
* @data:2020/11/03
* @reason:
* @description:/**
 * 高级搜索保存为数据分类
 * */

function  saveAsDataClass () {
	var popupobj = CrmPopup.getPopupObj("last");
	var that = this;
	//最后保存的方法
	that.save=function(){
		var  popupobj = CrmPopup.getPopupObj("last");
		// 获取分类名称
        var customViewName = ld.trim(CrmPopup.findHtmlobj(popupobj.divid,"customViewName").val());
		if(customViewName ==''){
			//名称为空直接提示
			RemindsMsg("","LdPopWidth400px","","yes","",arrJsPopLabel['CATEGORYNAMECANOTEMPTY']);
			return false;
		}
		//获取高级搜索
		var popupobjperv =CrmPopup.getPopupObj('lastprev');
        var advft_criteria =popupobjperv.advft_criteria;
        var advft_criteria_groups = popupobjperv.advft_criteria_groups;
        if(advft_criteria == '' || advft_criteria == '[]'){
            RemindsMsg("","LdPopWidth400px","","yes","",arrJsPopLabel['CONDITION']+arrJsPopLabel['CANOTEMPTY']);
            return false;
        }
        var cvmodule =popupobjperv.module; //视图module
		var record = getviewId(); //视图id
		var urlString = 'index.php?module=CustomView&action=CustomViewAjax&file=SearchToView&cvmodule='+cvmodule+'&record='+record+'&customViewName='+encodeURIComponent(customViewName)+'&advft_criteria='+encodeURIComponent(advft_criteria)+'&advft_criteria_groups='+encodeURIComponent(advft_criteria_groups);
        //zkt 20231012 XUQIU1001341 SQL注入
        ldAjaxNoProgress(urlString,'',function(data){
            if(data.code ==1){
                //关闭两个弹出层
                var popupobj = CrmPopup.getPopupObj("last");
                popupobj.CancelEvent();
                var popupobj = CrmPopup.getPopupObj("last");
                popupobj.CancelEvent();
                //刷新页面
                DataCategoryListPopup.save();
            }
            else{
                //提示错误
                RemindsMsg("","LdPopWidth400px","","yes","",data.result.msg);
                return false;
            }
        });
	}
	// 高级搜索条件 过滤并赋值
	if(popupobj.advanceFilterObj != undefined && !popupobj.advanceFilterObj.checkAdvancedFilter()){
        return false;
    }
	//弹出层
	var popupobj = CrmPopup.load(arrJsPopLabel['NEWCALASSIFICATION'],that.save,"","LdPopWidth600px",'',"",arrJsPopLabel['SAVE'],"",arrJsPopLabel['CANCEL']);
	var html ='<table class="ld-public-content-small" border="0" cellpadding="0" cellspacing="0" width="100%">'+
		'<tbody>'+
		'<td class="ld-form-item-label"><font color="red">*</font>'+arrJsPopLabel['CATEGORYNAME']+'</td>'+
		'<td class="ld-form-item-content">'+
		'<input type="text" class="ld-input-inner" name="customViewName" value="">'+
		'</td>'+
		'</tr>'+
		'</tbody></table>';
	CrmPopup.setPopupobjHtmlContent_scroll(popupobj,html);
}