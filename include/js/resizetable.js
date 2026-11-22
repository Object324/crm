function List_ResizeTable(popupobj)
{
    var that=this;
    this.popupobj=popupobj;
    this.module = popupobj.module;
    
    this.resizeInitVar_Value= function () {
        this.headerTds=[];
        this.tblObj=undefined;
        this.resize_mousemove=false;
        this.mousedown = false;
        this.resizeable = false;
        this.targetTd=[];
        this.screenXStart =0;
        this.tdWidth = 0;
        this.headerWidth = 0;
    }

    this.resizeTable_Column=function(tableid,modulename) {
        // resizeTable_Column.modulename=modulename;
        this.tblObj =ld("#"+that.popupobj.divid+" [name="+tableid+"]").get(0);//document.getElementById(tableid);
    	if(this.tblObj != undefined){
    		this.headerTds= this.tblObj.rows[0].cells;
            for(var i = 0;i<this.headerTds.length;i++){
    			addListener(this.headerTds[i],"mousedown",that.onmousedown);
    			addListener(this.headerTds[i],"mousemove",that.onmousemove);
    		}
    	}
        if(ld("#"+that.popupobj.divid+" #"+that.header_table_divid).get(0) > 0){
            addListener(ld("#"+that.popupobj.divid+" #"+that.header_table_divid).get(0),"mousemove",that.onmousemove);
            //addListener(document.body,"mousemove",that.onmousemove);
        }
    }
    
    this.onmousedown=function (event){
        if (that.resizeable == true){
            var evt =event||window.event;
            that.mousedown = true;
            that.screenXStart = evt.screenX;
            that.tdWidth = that.targetTd.offsetWidth;
            that.headerWidth = that.tblObj.offsetWidth;
        }
    }

    this.onmousemove=function(event){
        var evt =event||window.event;
        var srcObj = getTarget(evt);
        if(srcObj==undefined) return ;
        window.getSelection ? window.getSelection().removeAllRanges() : document.selection.empty();
        var offsetX = evt.offsetX || (evt.clientX - srcObj.getBoundingClientRect().left);//这个比较关键，解决了Firefox无offsetX属性的问题

        if (that.mousedown == true){
            var width = (that.tdWidth + (evt.screenX - that.screenXStart)) + "px";//计算后的新的宽度
            that.targetTd.style.width = width;
            that.tblObj.style.width = (that.headerWidth + (evt.screenX - that.screenXStart)) + "px";
            // 按钮行宽度,相关信息不需要
            if(that.popupobj != undefined && that.popupobj.type!='relatedpagelist')
            {
                if(ld('#'+that.header_tableid).width() >= ld('#'+that.fullwidth_divid).width()){
                    ld('.divButtons').css('width', ld('#'+that.fullwidth_divid).width());
                }
                else {
                    ld('.divButtons').css('width', ld('#'+that.header_tableid).width());
                }
            }

            var othertableid='';
            if(that.tblObj.id!=that.header_tableid)
            {
                othertableid=that.header_tableid;
            }
            else
            {
                othertableid=that.content_tableid;
            }
            
           //if(document.getElementById(othertableid)!=undefined)
         
           if(ld("#"+that.popupobj.divid+" [name="+othertableid+"]").length>0)
           {
               var othertable_obj=ld("#"+that.popupobj.divid+" [name="+othertableid+"]");
               var othertable_td_obj=othertable_obj.find("th[tag="+that.targetTd.getAttribute("tag")+"]");
               othertable_td_obj.css("width",that.targetTd.style.width );
               othertable_obj.css("width",(that.headerWidth + (evt.screenX - that.screenXStart)));
           }
            that.resize_mousemove=true;
        }else{
            if(that.tblObj==undefined)
            {
              return false;
            }
            var trObj = that.tblObj.rows[0];
            if(srcObj.offsetWidth - offsetX <=4){//实际改变本单元格列宽
                that.targetTd=srcObj;
                that.resizeable = true;
                srcObj.style.cursor='col-resize';//修改光标样式
            }else if(offsetX <=4 && srcObj.cellIndex > 0){//实际改变前一单元格列宽，但是表格左边框线不可拖动
                that.targetTd=trObj.cells[srcObj.cellIndex - 1];
                that.resizeable = true;
                srcObj.style.cursor='col-resize';
            }else{
                that.resizeable = false;
                srcObj.style.cursor='default';
            }
        }
    }

    this.setDivEvent=function(related_id){
    	var divid=this.popupobj.divid;
    	var fullwidth_divid=this.fullwidth_divid;//'hdScrolllistentries_yy';
    /*	if(!empty(related_id)){
    		divid = 'rel-left-div-'+related_id;
    		fullwidth_divid = popupobj.fullwidth_divid;
    	}*/
    	CrmPopup.findHtmlobj(divid,fullwidth_divid).mouseup(function(event){
    		that.tartgetTd = null;
    		if(that.resizeable==true&&that.resize_mousemove==true)
    		{
    			that.resizeTable_Column.save_customview_listview_width();
    		}
    		that.resizeable = false;
    		that.mousedown = false;
    		that.resize_mousemove=false;
    		document.body.style.cursor='default';
    	});	
        CrmPopup.findHtmlobj(divid,fullwidth_divid).find("th").mouseup(function(event){
    		that.tartgetTd = null;
    		if(that.resizeable==true&&that.resize_mousemove==true)
    		{
    			that.resizeTable_Column.save_customview_listview_width();
    		}
    		that.resizeable = false;
    		that.mousedown = false;
    		that.resize_mousemove=false;
    		document.body.style.cursor='default';
    	});	
        CrmPopup.findHtmlobj(divid,fullwidth_divid).find("th").find("img").mousedown(function(event){
    	  //edit:can 20210819 47004: （https://81mis.com/kfbcrm/ [^]）有时会出现序时簿列表按住时拉动无反应，松开鼠标后反而跟随鼠标移动
     	that.tartgetTd = null;
    		if(that.resizeable==true&&that.resize_mousemove==true)
    		{
    			that.resizeTable_Column.save_customview_listview_width();
    		}

    		that.resizeable = false;
    		that.mousedown = false;
    		that.resize_mousemove=false;
    		document.body.style.cursor='default';
    	});
        // wym 230301 详情页双击浮窗
        if (typeof listdoubleclickobj == "undefined" || listdoubleclickobj == undefined) {
            getJsScript('include/js/ListDoubleClick.js', function () {
                var listdoubleclickobj = new ListDoubleClick(popupobj);
                listdoubleclickobj.setDoubleClickEvent();
            })
        }else {
            listdoubleclickobj.resetPopupobj(popupobj);
        }
      
    }
    function getTarget(evt){
        return evt.target || evt.srcElement;
    }
    function addListener(element,type,listener,useCapture){
        element.addEventListener?element.addEventListener(type,listener,useCapture):element.attachEvent("on" + type,listener);
    }

    /*
    相关信息
    */
    this.setRelatedResizeTable_Init=function(module) {
        //return false;
        //180:是左边相关信息宽度
        //5:相关信息内容和左边间距
        var popupobj=that.popupobj;
        var divobj = ld('#'+popupobj.divid);
        that.resizeInitVar_Value();//初始化全局变量
        //var` related_id = ld('#hidden_related_id_'+module).val();
           
        var min_scroll_width=20;
        that.fullwidth_divid=ListView_Page.fullwidth_divid+"_"+module;
        that.header_table_divid=ListView_Page.header_table_divid+"_"+module;
        that.content_tableid=ListView_Page.content_tableid+"_"+module;
        that.content_table_divid=ListView_Page.content_table_divid+"_"+module;
        that.header_tableid=ListView_Page.header_tableid+"_"+module;
        var listmap_divobj = ld("#"+popupobj.divid+" #listmap_div");
        if(!empty(listmap_divobj)){
            ld(listmap_divobj).css("width",ld("#"+popupobj.divid).width()-min_scroll_width);
        }
        
        that.setDivEvent(popupobj.relateid);

        ld('#'+that.fullwidth_divid).css('width',ld("#"+popupobj.divid).width()-min_scroll_width);
        //alert(ListView_Page.header_tableid);

        that.resizeTable_Column(that.header_tableid,module);

        var width = divobj.width()-min_scroll_width;
        divobj.find("#"+that.header_table_divid).css("width",width);
        divobj.find("#"+that.content_tableid).css("width",width);
        divobj.find("#"+that.content_table_divid).css("width",width);
        divobj.find("#"+that.header_tableid).css("width",width);
        //zkt 20220616 52161（https://81mis.com/kfbcrm）合同订单SO156，相关创建发票，发票金额1，保存后界面显示2个拖动条
        if(ld('#'+popupobj.divid).find(' [ name=related_list_top_'+module+']')!=undefined&&ld('#'+popupobj.divid).find(' [ name=related_list_top_'+module+']').length>0)
        {
            ld('#'+popupobj.divid).find(' [ name=related_list_top_'+module+']').css('width',ld("#"+popupobj.divid).width()-min_scroll_width);
        }
        var scrollleft=ld("#"+popupobj.content_table_divid).scrollLeft();
        ld("#"+that.content_table_divid).scroll(function(event){
            if(scrollleft!=ld("#"+that.content_table_divid).scrollLeft())
            {
                ld("#"+that.header_table_divid).scrollLeft(ld("#"+that.content_table_divid).scrollLeft());
            }

            scrollleft=ld("#"+that.content_table_divid).scrollLeft();

        });
        if(typeof cls_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined"){
            //通讯录(pc端企业微信)
            cls_wxOpenDataobj.bindAllOpenDataByPopupObj(popupobj);
        }

    }

    //选择源单弹出层//自动查重合并弹出层
    this.setPopupResizeTable_Init=function (module)
    {
        that.resizeInitVar_Value();//初始化全局变量
        var popupobj=that.popupobj;
        var min_scroll_width=17;
        //diony 2024-08-26 查重结果滚动条先不减17
        if(popupobj.headname == 'Findduplicates' || popupobj.pop_type == 'selectBatchPopup'){
            min_scroll_width=0;
        }

        var divid=popupobj.divid;
        that.setData()
        that.setDivEvent();
        var popupwidth=parseInt( ld("#"+divid).css("width"));
        //diony 2024-08-26 查重结果左右两边各减24
        if(popupobj.headname == 'Findduplicates' || popupobj.pop_type == 'duplicatePopup' || popupobj.pop_type == 'selectBatchPopup'){
            popupwidth-=48;
        }
        if(ld("#"+divid+"_scroll").length>0){
            var popupscrollobj = ld("#"+divid+"_scroll");
        }
        if((ld("#"+divid+" [name=isshowPopupModuleListTree]").length>0&&ld("#"+divid+" [name=isshowPopupModuleListTree]").val()=='yes'))
        {
            var treeWidth = ld('#'+divid).find('#popupListViewModuleListTree').outerWidth(true);
            min_scroll_width = parseInt(treeWidth) + 32 + 3;
            // if(popupwidth<(parseInt(CrmPopup.findHtmlobj(divid,that.fullwidth_divid).css('width'))+min_scroll_width)){
            //     ld("#"+divid).css("width",popupwidth+min_scroll_width);
            //     popupwidth += min_scroll_width;
            // }
            // console.log(popupwidth);
            // console.log(treeWidth);
            // console.log(min_scroll_width);
            // console.log(parseInt(CrmPopup.findHtmlobj(divid,that.fullwidth_divid).css('width')));
            ld("#"+divid + ' #ListViewContents').find('table:first').css("width",popupwidth-min_scroll_width);//liushuai 20230713 合同订单新增界面，选择产品弹出层，超出
            CrmPopup.findHtmlobj(divid,that.fullwidth_divid).css('width',popupwidth-min_scroll_width);
            //popupobj.center();
        }
        else{
            CrmPopup.findHtmlobj(divid,that.fullwidth_divid).css('width',popupwidth-min_scroll_width);
        }


        that.resizeTable_Column(that.header_tableid,module);

        CrmPopup.findHtmlobj(divid,that.header_table_divid).css("width",popupwidth-min_scroll_width);

        CrmPopup.findHtmlobj(divid,'resize_popupsearch_tableid').css("width",popupwidth);
        CrmPopup.findHtmlobj(divid,that.content_table_divid).css("width",popupwidth-min_scroll_width);

        //zxm 20230905 表体没给宽度
        CrmPopup.findHtmlobj(divid,that.header_tableid).css("width",popupwidth-min_scroll_width);
        CrmPopup.findHtmlobj(divid,that.content_tableid).css("width",popupwidth-min_scroll_width);

        var scrollleft=CrmPopup.findHtmlobj(divid,that.content_table_divid).scrollLeft();
        CrmPopup.findHtmlobj(divid,that.content_table_divid).scroll(function(event){
            if(scrollleft!=CrmPopup.findHtmlobj(divid,that.content_table_divid).scrollLeft()){
                CrmPopup.findHtmlobj(divid,that.header_table_divid).scrollLeft(CrmPopup.findHtmlobj(divid,that.content_table_divid).scrollLeft());
            }
            scrollleft=CrmPopup.findHtmlobj(divid,that.content_table_divid).scrollLeft();
        });
        if(typeof cls_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined"){
            //通讯录(pc端企业微信)
            cls_wxOpenDataobj.bindAllOpenData();
        }
        //树结构调整高度
        if (ld('#'+divid).find('#isshowPopupModuleListTree') != undefined && ld('#'+divid).find('#isshowPopupModuleListTree').val() == 'yes'&&PopupModuleListTree!=undefined){
            PopupModuleListTree.setHeight();
        }

    }
    this.setReiszeTable_Init=function (module,pagetype) {
        var popupobj = that.popupobj;
        //lmq 230615 表格行高设置
        //wym 231225 BUG0077447 行高保存后没有刷新，要小圈转完了等2s才会刷新（改成了tpl加载对应class）
        /*if (popupobj.TableLineHightSet == 'compact') {
            ld('#resize_content_tableid').removeClass('listEntriesSpacious').addClass('listEntriesCompact');
        } else if (popupobj.TableLineHightSet == 'comfortable') {
            ld('#resize_content_tableid').removeClass('listEntriesCompact').removeClass('listEntriesSpacious');
        } else if (popupobj.TableLineHightSet == 'spacious') {
            ld('#resize_content_tableid').removeClass('listEntriesCompact').addClass('listEntriesSpacious');
        }*/
        that.resizeInitVar_Value();//初始化全局变量
        that.setData()
        //var popupobj=CrmPopup.getPopupObj('last')
        //  alert(ld("#crm_menu").width());
        that.setDivEvent();
        var min_scroll_width = 0;
        var userAgent = navigator.userAgent; //取得浏览器的userAgent字符串
        min_scroll_width = 20;
        var bodywidth = CrmPopup.getClientWidth();//ld('#crm_menu').width();
        bodywidth = bodywidth - parseInt(getLeftMenuWidth());

        var contentdvheight = parseInt(ld("#"+that.content_table_divid).css('height'));
        var contenttableheight = parseInt(ld("#"+that.content_tableid).css("height"));
        var isrest = 'yes';
        if (typeof FieldWidthSettingobj !== 'undefined') {
            ld.each(FieldWidthSettingobj, function (tmpindex, tmp_width) {
                if (isNaN(tmp_width)) {
                    isrest = 'no';
                    return true;
                }
            })
        }

        if (contenttableheight > contentdvheight && isrest == 'yes') {
            min_scroll_width = 20;
            //有滚动条,如果有滚动条重新计算列宽
            var content_tableid_obj = ld("#"+that.content_tableid);
            var tmpwidth = parseInt(content_tableid_obj.css("width")) - min_scroll_width;
            content_tableid_obj.css("width", tmpwidth + "px");
            content_tableid_obj.css("width", tmpwidth + "px");

            var thobjs = ld("#"+that.content_tableid).find("th");
            var header_thobjs = ld("#"+that.header_tableid).find("th");
            var tmplen = ld(thobjs).length - 2;//2:表示checkbox和操作列
            var min_averagewidth = 0;

            while (min_averagewidth < 1) {
                min_averagewidth = parseInt(min_scroll_width / tmplen);
                tmplen--;
            }

            var tmpwidth = 0;
            var min_totalwidth = 0;
            for (var i = 1; i <= tmplen; i++) {
                tmpwidth = parseInt(ld(ld(thobjs)[i]).css('width')) - parseInt(min_averagewidth);
                ld(ld(thobjs)[i]).css('width', tmpwidth + "px");
                ld(ld(header_thobjs)[i]).css('width', tmpwidth + "px");
                min_totalwidth += min_averagewidth;
            }

            var balancewidth = parseInt(ld(ld(thobjs)[i]).css('width')) - (min_scroll_width - min_totalwidth);
            ld(ld(thobjs)[i]).css('width', balancewidth + "px");
            ld(ld(header_thobjs)[i]).css('width', balancewidth + "px");
        }

        if (module == 'Users') {
            var treeWidth = 260;
            if(structureTreeobj){
                treeWidth = structureTreeobj.treeWidth;
            }
            if(ld('#structuretree').css('display') == 'none'){
                treeWidth = 0;
            }
            min_scroll_width = parseInt(treeWidth) + 17 + 3;
        }
        //zkt 【单据列表、选择产品界面增加树状结构】 重设右边列表宽度
        if (ld("#isshowModuleListTree").length > 0 && ld("#isshowModuleListTree").val() == 'yes') {
            var treeWidth = 220;
            if(structureTreeobj){
                treeWidth = structureTreeobj.treeWidth;
            }
            if(ld('#structuretree').css('display') == 'none'){
                treeWidth = 0;
            }
            min_scroll_width = parseInt(treeWidth) + 20;//237=220(树宽度) +12(展开收起图标宽度)
        }
        if (popupobj.pop_type == 'UnifiedSearch'){
            var scrollwidth = ld('#'+popupobj.divid).find('#UnifiedSearch').outerWidth(true);
            var clientwidth = ld('#'+popupobj.divid).find('#global_search_total').outerWidth(true);
            min_scroll_width = 20 + 20;
            if (scrollwidth > clientwidth){
                min_scroll_width = min_scroll_width + (scrollwidth - clientwidth);
            }
        }
        if (module == 'Reminds') {
            min_scroll_width = treeWidth = ld("#"+popupobj.divid).find('#ld-listview-left-categorytree').width() + 21;
        }
        // alert(min_scroll_width);
        // alert(ListView_Page.fullwidth_divid);
        ld('#' + that.fullwidth_divid).css('width', bodywidth - min_scroll_width);
        that.resizeTable_Column(that.header_tableid, module);
        ld("#" + that.header_table_divid).css("width", bodywidth - min_scroll_width);
        ld("#" + that.content_table_divid).css("width", bodywidth - min_scroll_width);
        //zxm  2021-0804 重设table宽度
        ld("#" + that.header_tableid).css("width", bodywidth - min_scroll_width);
        ld("#" + that.content_tableid).css("width", bodywidth - min_scroll_width);

        if (popupobj != undefined) {
            var scrollleft = ld("#" + popupobj.divid + " #" + that.content_table_divid).scrollLeft();
            ld("#" + popupobj.divid + " #" + that.content_table_divid).scroll(function (event) {
                if (scrollleft != ld("#" + popupobj.divid + " #" + that.content_table_divid).scrollLeft()) {
                    ld("#" + popupobj.divid + " #" + that.header_table_divid).scrollLeft(ld("#" + popupobj.divid + " #" + that.content_table_divid).scrollLeft());
                }
                scrollleft = ld("#" + popupobj.divid + " #" + that.content_table_divid).scrollLeft();
            });
        } else {
            var scrollleft = ld("#" + that.content_table_divid).scrollLeft();
            ld("#" + that.content_table_divid).scroll(function (event) {
                if (scrollleft != ld("#" + that.content_table_divid).scrollLeft()) {
                    ld("#" + that.header_table_divid).scrollLeft(ld("#" + that.content_table_divid).scrollLeft());
                }
                scrollleft = ld("#" + that.content_table_divid).scrollLeft();
            });
        }

        // 按钮行宽度
        if (ld('#'+that.header_tableid).width() >= ld('#'+that.fullwidth_divid).width()) {
            ld('.divButtons').css('width', ld('#'+that.fullwidth_divid).width());
        } else {
            ld('.divButtons').css('width', ld('#'+that.header_tableid).width());
        }

        //加载tip 20200629 diony
        tooltip(ld("#" + popupobj.divid).find('.tip-items-list'), {transition: true, time: 200});

        if (typeof cls_wxOpenDataobj != undefined && typeof cls_wxOpenDataobj != "undefined"){
            //通讯录(pc端企业微信)
            cls_wxOpenDataobj.bindAllOpenData();
        }

        //列表界面刷新时更新界面小编辑图标对应事件
        if (popupobj != undefined && popupobj.type == 'listpage') {
            if (typeof listeditpageobj == "undefined" || listeditpageobj == undefined) {
                getJsScript('include/js/SystemPopup/ListEditPagePopup.js', function () {
                    var listeditpageobj = new ListEditPagePopup(popupobj);
                    listeditpageobj.init();
                    listeditpageobj.setListEditEvent();
                })
            } else {
                listeditpageobj.init();
                listeditpageobj.setListEditEvent();
            }

            //产品管理-库存-下拉框位置
            if (popupobj.module == 'Products') {
                ld("#" + popupobj.divid + " #"+that.content_tableid).find("a.operatetool_more").hover(function () {
                    if (ld(this).data('type') != undefined && ld(this).data('type') == 'CRM+ERP') {
                        var inventorytop = this.offsetHeight + this.offsetTop + ld(this).parent().get(0).offsetTop;
                        var inventoryRight = ld(this).parent().get(0).clientWidth - this.offsetLeft;
                        ld(this).find('ol').css('top', inventorytop + 'px');
                        ld(this).find('ol').css('right', inventoryRight-90 + 'px');
                    }
                })
            }
        }

        // wym 230301 序时簿列表双击浮窗
        if (typeof listdoubleclickobj == "undefined" || listdoubleclickobj == undefined) {
            getJsScript('include/js/ListDoubleClick.js', function () {
                var listdoubleclickobj = new ListDoubleClick(popupobj);
                listdoubleclickobj.setDoubleClickEvent();
            })
        }else {
            listdoubleclickobj.resetPopupobj(popupobj);
        }
        //hzx 列表页面右侧抽屉
        if(ld('.customview_oplist_group_btn_content_management').length>0) {
            getJsScript('include/js/ListViewRightSetting.js', function () {
                ListViewRightSettingobj = new ListViewRightSetting();
                //BUG20240805-63
                var new_popup = CrmPopup.getlastPopupObjByPageType('listpage');
                ListViewRightSettingobj.resetPopupobj(new_popup);
            })
        }
        else{
            ld('#listviewrightsetting_icon').hide();
        }

    }


    this.resizeTable_Column.save_customview_listview_width=function()
    {
        var popupobj=that.popupobj;
        if (popupobj && popupobj.headermodule == 'PriceBooks' && popupobj.module == 'Products'){
            return false;
        }

        if(ld('#'+popupobj.divid).find(' [id='+that.header_tableid+']').length>0){
            that.header_Tds= ld('#'+popupobj.divid).find(' [id='+that.header_tableid+']').get(0).rows[0].cells;
        }
        else{
            that.header_Tds= document.getElementById(that.header_tableid).rows[0].cells;
        }
        var module=that.module;
        if (empty(module)){
            module = that.popupobj.module;
        }
        var str_width=',';

        //去掉第一列
        var i=0;
        /*if(module=='InventoryAccount'||module=='InventoryQuery')
        {
            i=0;
        }*/
        var headername=',';
        var headermodule=',';
        var list_type = '';
        var header_length = that.header_Tds.length ;
        var frommodule = '';
        //选择源单没有操作列
        if(ld('#popup_type') != undefined && (ld('#popup_type').val() == 'selectsource' || ld('#popup_type').val() == 'specific')){
            //header_length += 1;
            if(ld('#frommodule') != undefined && ld('#frommodule').val() != ''){
                frommodule = ld('#frommodule').val();
            }
        }
        for(i;i<header_length;i++){
            if(that.header_Tds[i].getAttribute("headername")==undefined)//操作列没有该属性，修改客户相关信息-》短信记录
            {
                continue;
            }
            headername+=that.header_Tds[i].getAttribute("headername")+',';
            headermodule+=that.header_Tds[i].getAttribute("headermodule")+',';
            if(that.header_Tds[i].style.width!='')
                str_width+=parseInt(that.header_Tds[i].style.width)+",";
            else
                str_width+="-1,";
        }
        var viewid = '';
        //相关信息 - 列表
        if(ld('#hidden_related_list') != undefined && ld('#hidden_related_list').val() == 'yes'){
            list_type = 'related_customview';
            if(document.getElementById("viewname_"+module) != undefined){
                viewid=document.getElementById("viewname_"+module).value;
            }
        }else if(ld('#popup_type') != undefined && (ld('#popup_type').val() == 'selectsource' || ld('#popup_type').val() == 'specific' || ld('#popup_type').val() == 'inventory_prod') || ld('#popup_type').val() == 'MultiplePopup'){
            list_type = 'popup_customview';
            if (ld('#'+popupobj.divid).find('#viewname').length > 0){
                viewid = ld('#'+popupobj.divid).find('#viewname').val();
            }else if(document.getElementById('viewname') != undefined){
                viewid = document.getElementById('viewname').value;
            }
        }
        else if(ld('#popup_type') != undefined && (ld('#popup_type').val() == 'mergduplicate' )){
            //自动查重合并
            list_type = 'mergduplicate_customview';
            if(document.getElementById('duplicate_viewid') != undefined){
                //自动查重合并的viewid是全部数据分类对应的viewid
                viewid = document.getElementById('duplicate_viewid').value;
            }
        }
        else if(popupobj.pop_type == 'chuantou_customview'){
            //首页-数据简报-数据穿透 列表拖动保存
            list_type = popupobj.pop_type;
            if(popupobj.viewid!= undefined){
                viewid = popupobj.viewid;
            }
        }
        else if (popupobj.pop_type == 'UnifiedSearch'){//全局查找的显示列表和对应模块列表保存一致
            list_type = 'customview';
            viewid = ld('#'+popupobj.divid + ' [name='+that.module+'_viewid]').val();
        }
        else if (popupobj.pop_type == 'duplicatePopup' || popupobj.pop_type == 'selectBatchPopup' ||  popupobj.pop_type == 'selectRelatedPopup'){
            list_type = popupobj.pop_type;
            viewid = 0;
        }
        else{
            list_type = 'customview';
            viewid=document.getElementById("viewname").value;
        }
        if(module=="SharedUsers"||module=='ViewHistory'){//共享或日志
            var urlstring='module=Users&action=UsersAjax&file=speciallistWidth&type='+module+"&listwidth="+str_width+"&viewid="+viewid+"&headername="+headername+"&headermodule="+headermodule+'&frommodule='+frommodule;
        }
        else{
            var urlstring='module='+module+"&action="+module+"Ajax&file=listWidth&type="+list_type+"&listwidth="+str_width+"&viewid="+viewid+"&headername="+headername+"&headermodule="+headermodule+'&frommodule='+frommodule;
        }
        //审批中心
        var pageto_module=getSearchString('pageto_module',location.href);

        //ls 20220825 BUG0055553 审批任务-已处理-设置列宽之后，重新设置查看范围，列宽就恢复默认了，没有记住设置(viewid没有传到后台，且approvestatus为空始终默认待处理页签)
        if(pageto_module == 'Approve'){
            if(ld('#approvestatus') != undefined){
                viewid = ld('#approvestatus').val();
                if(viewid == '')viewid = 0;
            }
            //数据分类
            var urlstring='module=Approve&action=ApproveAjax&file=listWidth&type='+list_type+"&listwidth="+str_width+"&viewid="+viewid+"&headername="+headername+"&headermodule="+headermodule+'&frommodule='+frommodule;
            //edit:can 20200728 42138: 审批中心->不能记住设置的列宽
            var page_addurl=getSearchString('page_addurl',location.href);
            if(ld('#approvestatus') != undefined){
                urlstring += '&approvestatus='+ld('#approvestatus').val();
            }
            var  fromapprovemodule=getSearchString('fromapprovemodule',page_addurl);

            //审批模块
            if(fromapprovemodule != undefined){
                urlstring += '&fromapprovemodule='+fromapprovemodule;
            }
        }
        ldAjaxHtmlNoProgress('index.php',urlstring,function (response) {

        });
    }
    this.setData = function (){
        var special_pop_type_arr = ['duplicatePopup',UnifiedSearch];
        if (special_pop_type_arr.indexOf(that.popupobj.pop_type) > -1 && !empty(that.module)){
            var module = that.module;
            that.fullwidth_divid = ListView_Page.fullwidth_divid+"_"+module;
            that.header_table_divid = ListView_Page.header_table_divid+"_"+module;
            that.content_tableid = ListView_Page.content_tableid+"_"+module;
            that.content_table_divid = ListView_Page.content_table_divid+"_"+module;
            that.header_tableid = ListView_Page.header_tableid+"_"+module;
        }else {
            that.fullwidth_divid = ListView_Page.fullwidth_divid;
            that.header_table_divid = ListView_Page.header_table_divid;
            that.content_tableid = ListView_Page.content_tableid;
            that.content_table_divid = ListView_Page.content_table_divid;
            that.header_tableid = ListView_Page.header_tableid;
        }
    }

}



