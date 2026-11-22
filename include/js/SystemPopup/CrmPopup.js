function CrmPopup() {
    var that = this;
    this.popupheadhtml = "";
    this.popupHtmlContent = "";
    this.scrolldiv = "";//添加弹出层滚动
    this.popupbottomhtml = "";
    this.popuppagetype = "";//当前弹出类型，//搜索框，编辑，创建
    this.popupInPageType = "";//当前弹出所在界面类型，列表，编辑，查看
    this.divid = "";//弹出层div
    this.type = "none";
    this.hide = false;
    this.btnokid = "";
    this.btncancelid = "";
    this.isshow = 'no';
    this.isprevshow = 'no';
    this.htmlcontent = "";
    this.position = '';
    this.prevshowcontent = '';
    this.popupMaxHeight = "";//设置弹出层最大高度
    this.height = -1;
    this.buttonPosition = 'center';
    this.isclicklayerclose = 'no';
    this.isread='no';//判断页面加载完成
    this.isfinishanimate='no';//判断动画效果是否加载完成
    this.fullscreenlabel='Fullscreen';//全屏缩小用于保存后台的label值

    ////Okfun:确认按钮调用的函数
    //Cancelfun:取消按钮的确认函数
    //cssSize:弹出层调用的css，设置弹出层的宽度
    //OkfunParamObj:确认按钮的参数，是一个对象，如果为undefined，则认为确认按钮函数无参数
    this.setParams = function (headtitle, Okfun, Cancelfun, cssWidth, module, OkfunParamObj, OkText, CancelfunParamObj, CancelText) {
        this.headtitle = headtitle;
        var result = /^\d+$/.test(cssWidth);
        if (result) {
            // cssWidth="LdPopWidth"+cssWidth+"px";
        }
        this.cssWidth = cssWidth;
        this.module = module;
        this.Okfun = Okfun;
        this.Cancelfun = Cancelfun;
        this.OkText = OkText;
        this.CancelText = CancelText;
        this.OkfunParamObj = OkfunParamObj;
        this.CancelfunParamObj = CancelfunParamObj;
    }
    this.setButtonPosition = function (buttonPosition) {
        this.buttonPosition = buttonPosition;
    }
    this.setHeadTitle = function (headtitle) {
        this.headtitle = headtitle;
    }
    this.setCssSize = function (cssSize) {
        this.cssSize = cssSize;
    }
    this.setPosition = function (position) {
        this.position = position;
    }
    //确认按钮的文字：
    this.setOkText = function (text) {

        this.OkText = text;
    }
    //取消按钮文字
    this.setCancelText = function (text) {
        this.CancelText = text;
    }
    this.setOkfun = function (Okfun) {
        this.Okfun = Okfun;
    }
    this.setOkfunParamObj = function (OkfunParamObj) {
        this.OkfunParamObj = OkfunParamObj;
    }

    this.setCancelfun = function (Cancelfun) {
        this.Cancelfun = Cancelfun;
    }
    this.setCancelfunParamObj = function (CancelfunParamObj) {
        this.CancelfunParamObj = CancelfunParamObj;
    }
    this.CancelEvent = function () {
        if (this.crmpopuplayerobj == undefined) {
            return;
        }
        CrmPopup.zIndex--;
        var Popup_Drag = new PopupDrag(this,this.divid);
        document.removeEventListener('mousemove', Popup_Drag.handleMousemove);//清除remove监听
        this.crmpopuplayerobj.unblock();
        if (document.getElementById(this.divid) != undefined && document.getElementById(this.divid) != 'undefined') {
            document.getElementById(this.divid).style.display = "none";
            document.body.removeChild(document.getElementById(this.divid));
        }
        var tmpobj = CrmPopup.global_listPopupObj[CrmPopup.global_listPopupObj.length - 1];

        CrmPopup.global_listPopupObj.pop();//把最后一个对象移除，移除当前弹出层的对象
        for (var i = 0; i < CrmPopup.global_signleInstance.length; i++) {
            if (CrmPopup.global_signleInstance[i].type == tmpobj.type) {
                CrmPopup.global_signleInstance.splice(i, 1);
                break;
            }
        }
        delete tmpobj;
        if (CrmPopup.global_listPopupObj.length > 0) {
            //判断上一个弹出层是否隐藏，如果隐藏了，则把他显示出来
            var obj = CrmPopup.global_listPopupObj[CrmPopup.global_listPopupObj.length - 1];
            if (obj.hide == true) {
                obj.reshow();
            }
        }

    }
    //滚动条
    this.createScrollDiv = function () {
        //var maxheight=this.getMaxHeight();
        this.scrolldiv = '<div class="dvpopupsroll" style="max-height:1200px;width: 100%;overflow-y:auto;">';
    }
    //设置弹出层的最大高度
    this.setScrollDivMaxHeight = function () {
        var that = this;
        var maxheight = this.getMaxHeight();
        // maxheight=maxheight+"px";
        ld("#" + this.divid + " .dvpopupsroll").css("max-height", maxheight);

    }
    this.setHeight = function (height) {
        this.height = height
    }
    this.getMaxHeight = function () {

        var popupheight = ld("#" + this.divid).height();
        var windowheight = CrmPopup.getClientHeight();

        if (popupheight + 10 > windowheight){
            var maxheight = CrmPopup.getClientHeight();
            if(ld("#" + this.divid + '_head').length>0){
                maxheight -= ld("#" + this.divid + '_head').outerHeight();
            }
            if(ld("#" + this.divid + '_popupbottom').length>0){
                maxheight -= ld("#" + this.divid + '_popupbottom').outerHeight();
            }
        }
        else{//39826: （51mis.com/kfbtest）加班单/合同订单模块>新建单据界面：产品分录新增多个产品行，看不到“保存”按钮
            var maxheight = CrmPopup.getClientHeight();
            if(ld("#" + this.divid + '_head').length>0){
                maxheight -= ld("#" + this.divid + '_head').outerHeight();
            }
            if(ld("#" + this.divid + '_popupbottom').length>0){
                maxheight = maxheight - 2 *ld("#" + this.divid + '_popupbottom').outerHeight();
            }
        }
        this.maxheight = maxheight;
        return this.maxheight;
    }
    /*
    创建最外围的弹出层
    */
    this.createBoundDiv = function () {
        this.divid = this.module + "_" + this.type + CrmPopup.zIndex;
        var divObj = document.createElement("div");
        divObj.setAttribute('id', this.divid);

        if (this.cssWidth == "") {
            divObj.className = 'E_pop_box';
            ld("#" + this.divid).css("width", "webkit-fit-content");
            ld("#" + this.divid).css("margin", "auto");
        } else if (this.cssWidth == 'auto') {
            divObj.className = 'E_pop_box ';
        } else {
            var result = /^\d+(\.\d+)?$/.test(this.cssWidth);
            if (result) {

                // cssWidth="LdPopWidth"+cssWidth+"px";
                divObj.className = 'E_pop_box ';
                divObj.style.width = this.cssWidth + "px";

            } else divObj.className = 'E_pop_box ' + this.cssWidth;
        }
        divObj.style.position = "fixed";
        divObj.style.zIndex = CrmPopup.zIndex;
        divObj.style.top = "120px";

        if (this.height != '-1') {
            divObj.style.height = this.height + "px"
        }
        //  divObj.style.left = "350px";
        divObj.style.display = "none";
        document.body.appendChild(divObj);
        //ld("#"+this.divid).css("-moz-user-select","none");//拖动禁止选中文字
        //  ld("#"+this.divid).css("-webkit-user-select","none");//拖动禁止选中文字
        //  ld("#"+this.divid).css("user-select","none");//拖动禁止选中文字
    }
    /*
    创建弹出层标题栏
    */
    this.createHeadHtml = function () {
        this.popupheadhtml = '<div class="E_pop_tit" id="' + this.divid + '_head" style="cursor:move">';
        this.popupheadhtml += '<strong class="E_ptita">' + this.headtitle + '</strong>';
        /* 赛可出行
        * edit: chj
        * date: 2020/8/11
        * reason: 流转、更新、结案、结案备注
        */
        var popupobj = CrmPopup.getPopupObj("last");
        if (this.module == 'Accounts' && typeof (version_account) != "undefined" && version_account != undefined && version_account == 'saic') {
            if (popupobj.type == 'createpage' || popupobj.type == 'pagerecord') {
                this.popupheadhtml += '<a href="javascript:;" tag="closedremarks" value="结案备注" onclick="saic_save_account(ld(this),event);return false;" style="padding-right:50px;">结案备注</a>';
                this.popupheadhtml += '<a href="javascript:;" tag="closed" value="结案" onclick="saic_save_account(ld(this),event);return false;">结案</a>';
                this.popupheadhtml += '<a href="javascript:;" tag="wander" value="流转" onclick="saic_save_account(ld(this),event);return false;">流转</a>';
                this.popupheadhtml += '<a href="javascript:;" tag="submit1" value="提交" onclick="saic_save_account(ld(this),event);return false;">提交</a>';
                this.popupheadhtml += '<a href="javascript:;" tag="update" value="更新" onclick="saic_save_account(ld(this),event);return false;">更新</a>';
                this.popupheadhtml += '<a href="javascript:;" tag="zancun" value="暂存" onclick="saic_save_account(ld(this),event)">暂存</a>';
            }
        }
        this.popupheadhtml+='<div class="E_pop_tit_Second_Right">';
        if ((this.module == "CustomEcharts") && popupobj != undefined && popupobj.isShowDetail == 'yes') {
            var report_type = popupobj.report_type;
            if (popupobj.permit_editview != undefined && popupobj.permit_editview == "yes") {
                this.popupheadhtml += '<div class="ld-button ld-button-primary" data-id="' + that.report_id + '" frompage="fromdetail" onclick="ReportAnalysisObj.creat_new_chart(this,\'' + report_type + '\')">' + arrJsPopLabel["EDIT"] + '</div>';
            }
        }
        //wym XUQIU1001820 弹出层添加全屏按钮，关闭按钮title也修改为tip
        if(this.isShowFullscreen){
            this.popupheadhtml += "<i class='ld-fonticon ld-fonticon-gobig tip-items-pop' data-tip='" + arrJsPopLabel['FULLSCREEN'] + "' data-direction='left' data-type='position' id='"+ this.divid +"_fullscreen' switchtotype='fullscreen'></i> ";
        }
        this.popupheadhtml += '<div class="ld-fonticon ld-fonticon-close tip-items-pop" value="' + arrJsPopLabel['LBL_CLOSE'] + '" data-tip="' + arrJsPopLabel['LBL_CLOSE'] + '" data-direction="bottom" data-type="position"  id="' + this.divid + '_imgclose"></div>';
        this.popupheadhtml += '</div>';
        this.popupheadhtml += '</div>';

    }
    /*
    创建弹出层底部包括按钮
    */
    this.createTextBeforeSave = function () {
        return '';
    }
    this.createBottomHtml = function () {
        var ok_class = '';
        var buttonpositionstyle = "";
        if (this.buttonPosition == 'center') {
            //   buttonpositionstyle=" style='text-align:center;width:100%;position:absolute;bottom:0px'";
        } else if (this.buttonPosition == 'right') {
            buttonpositionstyle = " style='text-align:right;width:100%;position:absolute;bottom:0px'";

        }
        if (this.OkText != undefined && this.OkText != "" && this.CancelText != "" && this.CancelText != undefined) {
            this.popupbottomhtml = '<div class="E_pbtn" ' + buttonpositionstyle + ' id="' + this.divid + '_popupbottom"> ';
            var funname = this.Okfun.funname;
            if (funname == undefined) {
                funname = this.Okfun.name;
            }
            this.popupbottomhtml += this.createTextBeforeSave();
            this.popupbottomhtml += '<input name="button" id="' + this.divid + '_btnok" class="E_pbtnok ld-button ld-button-primary' + ok_class + '" value="' + this.OkText + '" tagClick="' + funname + '"  type="button">';
            this.popupbottomhtml += '<input name="button" class="E_pbtncancel ld-button ld-button-cancel" value="' + this.CancelText + '" id="' + this.divid + '_btncancel" type="button">'

            this.popupbottomhtml += ' </div>';
            this.btnokid = this.divid + "_btnok";
            this.btncancelid = this.divid + "_btncancel";
        } else if (this.OkText != undefined && this.OkText != "") {
            var funname = this.Okfun.funname;
            if (funname == undefined) {
                funname = this.Okfun.name;
            }
            this.popupbottomhtml = '<div class="E_pbtn" ' + buttonpositionstyle + ' id="' + this.divid + '_popupbottom"> ';
            this.popupbottomhtml += '<input name="button" id="' + this.divid + '_btnok" class="E_pbtnok ld-button ld-button-primary' + ok_class + '" value="' + this.OkText + '" tagClick="' + funname + '"  type="button">';
            this.popupbottomhtml += ' </div>';
            this.btnokid = this.divid + "_btnok";
        } else if (this.CancelText != "" && this.CancelText != undefined) {
            this.popupbottomhtml += '<input name="button" class="E_pbtncancel ld-button ld-button-cancel" value="' + this.CancelText + '" id="' + this.divid + '_btncancel" type="button">'
            this.popupbottomhtml += ' </div>';
            this.btnokid = this.divid + "_btnok";
            this.btncancelid = this.divid + "_btncancel";
        }
    }
    this.hidepopup = function () {
        document.getElementById(this.divid).style.display = "none";
        this.hide = true;
    }
    /**
     重新加载内容
     **/
    this.reload = function (htmlcontent) {
        document.getElementById(this.divid).innerHTML = this.popupheadhtml + htmlcontent + this.popupbottomhtml;
        document.getElementById(this.divid).style.display = "block";
        this.setEvent();
    }
    this.setInnerHtml = function () {
        if (this.scrolldiv != "") {
            document.getElementById(this.divid).innerHTML = this.popupheadhtml + this.scrolldiv + this.htmlcontent + "</div>" + this.popupbottomhtml;
        } else document.getElementById(this.divid).innerHTML = this.popupheadhtml + this.htmlcontent + this.popupbottomhtml;
        document.getElementById(this.divid).style.display = "block";
    }
    this.getpopupMaxHeight = function () {
        return this.popupMaxHeight;
    }

    this.getPrevShowContent = function(){
        this.popupMaxHeight = this.getpopupMaxHeight();
        var prevshowcontent = '';
        if (this.popupMaxHeight > 0) {
            //可以设置全屏显示，例如查看，编辑，新增界面
            ld("#" + this.divid).css("max-height", this.popupMaxHeight);
            var topcenterpx = this.getMaxHeight() / 2 + "px";
            // var result = /^\d+$/.test(this.cssWidth);//BUG0058425 下面判断是为了添加px，当this.cssWidth为小数时，正则始终为false就失去了意义。换种方式
            if (this.cssWidth.toString().indexOf('px') > -1) {
                var result = false;
            } else {
                var result = true;
            }

            if (result) {
                var leftcenterpx = this.cssWidth / 2 + "px";
                prevshowcontent = "<div name='prevshowdv' style='height:" + this.getMaxHeight() + "px;width:" + this.cssWidth + "px'>";
            } else {
                prevshowcontent = "<div name='prevshowdv' style='height:" + this.getMaxHeight() + "px;width:" + this.cssWidth + "'>";

                var leftcenterpx = parseInt(this.cssWidth.substr("LdPopWidth".length, this.cssWidth.length - "LdPopWidth".length - 2)) / 2 + "px";

            }
            if (CrmPopup.start_progressObjs.length < 1) {
                // prevshowcontent += "<img src='themes/images/pageprogress.gif'  style='position:absolute;top:" + topcenterpx + ";left:" + leftcenterpx + "' />";
                prevshowcontent +=  '<div class="el-loading-mask ld-loading-mask">' +
                                    '    <div class="el-loading-spinner">' +
                                    '        <svg viewBox="25 25 50 50" class="circular"><circle cx="50" cy="50" r="20" fill="none" class="path"></circle></svg>' +
                                    '    </div>' +
                                    '</div>';
                CrmPopup.start_progressObjs.push('');
            }
            prevshowcontent += " </div>";
        }
        else {
            if (CrmPopup.start_progressObjs.length < 1) {
                // prevshowcontent = "<div style='text-align:center;padding-top: 10px;'><img src='themes/images/pageprogress.gif' /><div>";
                var loading_spinner_style = '';
                if (this.OkText != 'none') {
                }
                else{
                    loading_spinner_style = 'margin-top:-5px;';
                }
                prevshowcontent =   '<div class="el-loading-mask ld-loading-mask ld-loading-mask-pop">' +
                                    '    <div class="el-loading-spinner" style="'+loading_spinner_style+'">' +
                                    '        <svg viewBox="25 25 50 50" class="circular"><circle cx="50" cy="50" r="20" fill="none" class="path"></circle></svg>' +
                                    '    </div>' +
                                    '</div>';
                CrmPopup.start_progressObjs.push('');
            }
        }
        //this.prevshowcontent = prevshowcontent;
        return prevshowcontent;
    }
    this.prevshow = function () {
        this.createBoundDiv();//创建最外围的弹出层div,
        this.createHeadHtml();//创建弹出层标题
        this.createBottomHtml();//创建弹出层底部
        this.prevshowcontent = this.getPrevShowContent();


        this.crmpopuplayerobj = new CrmPopupLayer(this);
        this.crmpopuplayerobj.block();

        this.popupbottomhtml = '<div class="E_pbtn" id="' + this.divid + '_popupbottom"> ';
        if (this.OkText != 'none') {
            var okText = arrJsPopLabel['SAVE'];
            if(this.OkText!=''){
                okText = this.OkText;
            }
            var cancelText = arrJsPopLabel['CANCEL'];
            if(this.CancelText!=''){
                cancelText = this.CancelText;
            }
            this.popupbottomhtml += '<input name="button" id="' + this.divid + '_btnok" class="E_pbtnok ld-button ld-button-primary" value="'+okText+'" type="button">';
            this.popupbottomhtml += '<input name="button" class="E_pbtncancel ld-button ld-button-cancel" value="'+cancelText+'" id="' + this.divid + '_btncancel" type="button">'
        }
        this.popupbottomhtml += ' </div>';
        ld("#" + this.divid).html(this.popupheadhtml + this.prevshowcontent + this.popupbottomhtml);
        document.getElementById(this.divid).style.display = "block";
        this.popupbottomhtml = "";
        this.isprevshow = 'yes';
        this.pushobj();

        if (this.position == '' || this.position == CrmPopup.Positions.center) this.center(); else if (this.position == CrmPopup.Positions.right) CrmPopup.right(ld("#" + this.divid), this); else if (this.position == CrmPopup.Positions.rightcenter) CrmPopup.rightCenter(ld("#" + this.divid), this);
        // ljj 2023-08-22 BUG0070720 kfbcrm-单据详情页的头部的标题和x 还是title 应该改掉
        // tooltip('.tip-items-list', {transition: true, time: 200});
    }
    
    this.PopupAllReadFun=function(){
          //页面全部加载完成 包括动画
    };
    this.show = function (htmlcontent) {
        var that = this;
        if (this.isshow != "no") {

            this.reload(htmlcontent);
            return;
        }
        this.popupHtmlContent = htmlcontent;

        if (this.isprevshow == 'no') {

            this.createBoundDiv();//创建最外围的弹出层div,
            this.crmpopuplayerobj = new CrmPopupLayer(this);
            this.crmpopuplayerobj.block();
        }
        this.createHeadHtml();//创建弹出层标题
        this.createBottomHtml();//创建弹出层底部


        this.htmlcontent = htmlcontent;
        this.setInnerHtml();


        this.isshow = 'yes';
        DelProgressObjs();
        this.setSelectPopupListSize();
        var that = this;

        if (this.position == '' || this.position == CrmPopup.Positions.center) this.center(); else if (this.position == CrmPopup.Positions.rightcenter) {
            that.rightCenter();
        } else if (this.position == CrmPopup.Positions.right) {
            if (this.isprevshow == 'yes') {
                //不需要动画
                that.rightCenter();
            } else that.right();
        }
        // var that=this;
        /* ld(window).scroll(function(){
         that.center();
        });*/
        /*ld(window).resize(function () {

            that.reSizePosition();
        });*/
        this.setEvent();
        CrmPopup.zIndex++;
        if (this.isprevshow == 'no') this.pushobj();

        if (ld("#" + this.divid + " .dvpopupsroll")) {
            ld("#" + this.divid + " .dvpopupsroll").attr("id", this.divid + "_scroll");


            ld("#" + that.divid + "_scroll").scroll(function () {
                //隐藏带搜索的下拉框

                //  if(ld(" .chzn-drop").find("cssposition")=='fixed')
                //        ld(" .chzn-drop").css("display",'none');
                //edit:can 2020728 042121: （公司自用账套）服务合同模块>序时簿界面：勾选单据点击“批量编辑”，点击“合同类型”下拉框看不到“下拉选项”
                if (ld("#" + that.divid).find("[cssposition=fixed]").length > 0) ld("#" + that.divid).find("[cssposition=fixed]").css('display', 'none');
                //隐藏查看界面的小编辑按钮
                ld("#" + that.divid + " [name=crmspanid]").css("display", 'none');

            })

        }

        ld("#" + this.crmpopuplayerobj.opopupblocknodeid).unbind("click").bind("click", function () {

            if (that.isclicklayerclose == 'yes') {
                //点击遮罩层关闭弹出
                ld("#" + that.divid + "_imgclose").get(0).click();
            }
        });
        // ljj 2023-08-22 BUG0070720 kfbcrm-单据详情页的头部的标题和x 还是title 应该改掉
        // tooltip('.tip-items-list', {transition: true, time: 200});
        // tooltip('.tip-items-pop', {transition: true, time: 200});
    }
    this.setSelectPopupListSize = function () {

        if (this.cssWidth == '') {

            //目前选择的弹出框
            //宽度字适应,选择原单界面（例如出库单选择合同订单)
            var windowWidth = CrmPopup.getClientWidth();
            //ld("#resize_header_tableid").css("width")
            var divwidth = parseInt(ld("#" + this.divid + " [name=hdScrolllistentries_yy]").css("width"));

            if (windowWidth <= divwidth) {
                divwidth = windowWidth;
            }
            if (windowWidth - divwidth < 100) {
                //比整个界面的宽度少100个像素
                var minwidht = (100 - Math.abs(windowWidth - divwidth));
                var tmpwidth = divwidth - minwidht;
                ld("#" + this.divid).css("width", tmpwidth + "px");
            } else {
                if (isNaN(divwidth)) {
                    //edit:can 2021-01-08 44163: （本地php72，8.3.6）销售管理-销售机会-相关；在销售机会的相关信息，客户中，选择客户，弹出层异常，没有居中；
                    ld("#" + this.divid).css("width", windowWidth * 0.9);
                } else ld("#" + this.divid).css("width", divwidth);
            }
            this.setassignDivMaxheight('resize_content_table_divid');

        }
    }
    //指定div最大高度
    this.setassignDivMaxheight = function (divid) {
        var maxheight = this.getMaxHeight();
        ld("#" + divid).css("max-height", maxheight - 94 - 100);
    }
    this.pushobj = function () {
        CrmPopup.global_listPopupObj.push(this);
    }
    this.reSizePosition = function () {
        if (this.position == '' || this.position == CrmPopup.Positions.center) this.center(); else if (this.position == CrmPopup.Positions.right) {
            //不需要动画
            this.rightCenter();
        }
    }
    //(可以重载)
    this.right = function () {
        var obj = ld("#" + this.divid);
        CrmPopup.right(obj, this);
    }
    this.rightCenter = function () {
        if (!empty(this.popupdivid)) {
            this.divid = this.popupdivid;
        }
        var obj = ld("#" + this.divid);
        CrmPopup.rightCenter(obj, this);
    }
    //垂直居中
    this.verticalCenter = function () {
        var obj = ld("#" + this.divid);
        CrmPopup.verticalCenter(obj, this);
    }
    //弹出框居中(可以重载)
    this.center = function () {
        var obj = ld("#" + this.divid);
        CrmPopup.center(obj, this);
    }

    this.setEvent = function () {
        var that = this;

        PopupDrag(this, this.divid);   //弹出层拖拽
        document.getElementById(this.divid).onclick = function () {

            ld(" .chzn-drop").css("display", 'none');
            if (ld('#' + this.divid + ' input[tag=cur_input_select]') != undefined && ld('#' + this.divid + ' input[cur_input_select=yes]').attr('name') != undefined) {
                var input_select_name = new Array();
                var input_select_name = ld('#' + this.divid + ' input[cur_input_select=yes]').attr('name').split('cmb_span_optiontext_');
                if (ld('#' + this.divid + ' input[name=' + input_select_name[1] + ']').val() != undefined) {
                    if (ld('#' + this.divid + ' input[name=' + input_select_name[1] + ']').val() != '') {
                        var before_cur_input_select = ld('#' + this.divid + ' input[name=' + input_select_name[1] + ']').val();
                        ld('#' + this.divid + ' input[cur_input_select=yes]').val(before_cur_input_select);
                    } else {
                        ld('#' + this.divid + ' input[cur_input_select=yes]').val('');
                    }
                    ld('#' + this.divid + ' input[cur_input_select=yes]').attr('cur_input_select', 'no');
                } else if (ld('#' + this.divid + ' [name=' + input_select_name[1] + '] option:selected').val() != undefined) {
                    var before_cur_input_select = ld('#' + this.divid + ' [name=' + input_select_name[1] + '] option:selected').text()
                    ld('#' + this.divid + ' input[cur_input_select=yes]').val(before_cur_input_select);
                }
            }
            //chj 2021/1/5 44070: （https://61mis.com/kfbcrm [^]）（云泰五金）合同订单-产品分录-输入了产品名称之后会出现了模糊搜索的结果。这个搜索的结果只有在选择之后才会消失，这样会挡住下方产品的选择，希望可以点一下旁边的空白界面，搜索的结果就消失。
            if (ld('#' + this.divid + ' div[name=search_productname]') != undefined && ld('#' + this.divid + ' div[name=search_productname]') != 'undefined') ld('#' + this.divid + ' div[name=search_productname]').hide();
        }
        if (this.OkText != "" && this.OkText != undefined && this.Okfun != "" && this.Okfun != undefined) {

            document.getElementById(this.divid + '_btnok').onclick = function () {
                if (that.OkfunParamObj != "" && that.OkfunParamObj instanceof Array) {
                    // console.log(that.OkfunParamObj.length);
                    switch (that.OkfunParamObj.length) {
                        case 0:

                            that.OkfunParamObj['button'] = this;
                            that.Okfun.call(this, that.OkfunParamObj);
                            break;
                        case 1:
                            that.Okfun.call(this, that.OkfunParamObj[0]);
                            break;
                        case 2:
                            that.Okfun.call(this, that.OkfunParamObj[0], that.OkfunParamObj[1]);
                            break;
                        case 3:
                            that.Okfun.call(this, that.OkfunParamObj[0], that.OkfunParamObj[1], that.OkfunParamObj[2]);
                            break;
                        case 4:
                            that.Okfun.call(this, that.OkfunParamObj[0], that.OkfunParamObj[1], that.OkfunParamObj[2], that.OkfunParamObj[3]);
                            break;
                        case 5:
                            that.Okfun.call(this, that.OkfunParamObj[0], that.OkfunParamObj[1], that.OkfunParamObj[2], that.OkfunParamObj[3], that.OkfunParamObj[4]);
                            break;
                        case 6:
                            that.Okfun.call(this, that.OkfunParamObj[0], that.OkfunParamObj[1], that.OkfunParamObj[2], that.OkfunParamObj[3], that.OkfunParamObj[4], that.OkfunParamObj[5]);
                            break;
                        case 7:
                            that.Okfun.call(this, that.OkfunParamObj[0], that.OkfunParamObj[1], that.OkfunParamObj[2], that.OkfunParamObj[3], that.OkfunParamObj[4], that.OkfunParamObj[5], that.OkfunParamObj[6]);
                            break;
                        case 8:
                            that.Okfun.call(this, that.OkfunParamObj[0], that.OkfunParamObj[1], that.OkfunParamObj[2], that.OkfunParamObj[3], that.OkfunParamObj[4], that.OkfunParamObj[5], that.OkfunParamObj[6], that.OkfunParamObj[7]);
                            break;
                        case 9:
                            that.Okfun.call(this, that.OkfunParamObj[0], that.OkfunParamObj[1], that.OkfunParamObj[2], that.OkfunParamObj[3], that.OkfunParamObj[4], that.OkfunParamObj[5], that.OkfunParamObj[6], that.OkfunParamObj[7], that.OkfunParamObj[8]);
                            break;
                    }
                } else {
                    that.Okfun(that.OkfunParamObj);
                }
                return false;
            }
        }

        if (document.getElementById(this.divid + '_fullscreen') != undefined) {
            document.getElementById(this.divid + '_fullscreen').onclick = function () {
                that.switchFullscreen();
            }
        }

        document.getElementById(this.divid + '_imgclose').onclick = function () {
            if (that.Cancelfun != "" && that.Cancelfun != undefined) {
                CrmPopup.Cancel(that.Cancelfun, that.CancelfunParamObj);
            }
            that.CancelEvent();

            //作用：相关信息点击关闭按钮会刷新
            return false;
        }
        if (this.CancelText != "" && this.CancelText != undefined && document.getElementById(this.divid + '_btncancel') != undefined) {
            document.getElementById(this.divid + '_btncancel').onclick = function () {
                if (that.Cancelfun != "" && that.Cancelfun != undefined) {

                    CrmPopup.Cancel(that.Cancelfun, that.CancelfunParamObj)
                }
                that.CancelEvent();
            }
        }
    }
    //重新显示
    this.reshow = function () {

        document.getElementById(this.divid).style.display = "block";
        this.hide = false;
    }
    this.getbtnOkobj = function () {
        return document.getElementById(this.divid + '_btnok');
    }
    this.picklist_end_foucs = function (event, fieldname) {
        var e = event || window.event;
        var obj = e.srcElement || e.target;//查询文本框
        //chj 2021/7/19 46827: （81mis.com/kfbcrm）客户管理-客户，单据列表处，先点开数据分类，不选择 再点开查看范围，数据分类下拉选项不会收起
        ld(" .chzn-drop").css("display", 'none');
        if (ld(obj).attr("picklisttype") == 'smownerpicklist') {
            if (document.selection) {
                var range = document.body.createTextRange();
                range.moveToElementText(obj);
                range.select();

                document.getSelection().getRangeAt(0);//找到焦点位置
            } else if (window.getSelection) {
                var range = document.createRange();
                range.selectNodeContents(obj);
                window.getSelection().removeAllRanges();
                window.getSelection().addRange(range);
                range = window.getSelection().getRangeAt(0);//找到焦点位置

            }
        } else ld("#" + this.divid + " [name=cmb_span_optiontext_" + fieldname + "]").select();
    }
    //wym XUQIU1001820 目前仅首页数据简报使用,恢复时高度为全屏高,后续如果要公用还需再修改
    //wym XUQIU1001421 关联选择单据（单选）、关联选择单据（多选）、选择源单、分录选择产品弹出层中，增加“全屏/恢复”图标按钮（郭惠宇）
    this.switchFullscreen = function () {
        var obj = ld("#" + this.divid);
        var fullscreen_obj = ld("#" + this.divid + "_fullscreen");
        var windowHeight = CrmPopup.getClientHeight();
        var windowWidth = CrmPopup.getClientWidth();
        var switchtotype = fullscreen_obj.attr('switchtotype');
        var Fullscreen='';
        if(switchtotype=="fullscreen"){//全屏
            var smallheight = obj.height();
            fullscreen_obj.attr('small-height',smallheight);
            var bigwidth = this.getBigpopupwidth();
            //wym XUQIU1002278 二级弹窗的全屏只能是屏幕的90%
            obj.css({
                "position": "fixed",
                "height": windowHeight,
                "width": bigwidth,
                "top": 0,
                "left": (windowWidth-bigwidth)/2
            });
            fullscreen_obj.attr('switchtotype','recovery');
            fullscreen_obj.attr('data-tip',arrJsPopLabel['RECOVERY']);
            fullscreen_obj.removeClass("ld-fonticon ld-fonticon-gobig");
            fullscreen_obj.addClass("ld-fonticon ld-fonticon-gosmall");
            Fullscreen='yes';
        }else{//缩小
            var smallwidth = this.getSmallpopupwidth();
            //var smallheight = parseInt(fullscreen_obj.attr('small-height'));
            if(smallheight === null || smallheight === undefined ){
                smallheight= windowHeight*0.8 ;
            } else if(this.pagetype=='homestuffchuantou'){
                smallheight = windowHeight;
            }
            obj.css({
                "position": "fixed",
                "height": 'auto',
                "width": smallwidth,
                "top": (windowHeight-smallheight)/2,
                "left": (windowWidth-smallwidth)/2
            });
            fullscreen_obj.attr('switchtotype','fullscreen');
            fullscreen_obj.attr('data-tip',arrJsPopLabel['FULLSCREEN']);
            fullscreen_obj.removeClass("ld-fonticon ld-fonticon-gosmall");
            fullscreen_obj.addClass("ld-fonticon ld-fonticon-gobig");
            Fullscreen='no';
        }
        if(this.fullscreenlabel!='' && this.fullscreenlabel!='undefined' && this.fullscreenlabel!=undefined) {
            var urlstring = "index.php?module=Users&action=UsersAjax&file=ModuleSettingbyuser&mode=save&curmodule="+this.module+"&label="+this.fullscreenlabel+"&content="+Fullscreen;
            ldAjaxNoProgress(urlstring,'',function(data) {});
        }
        this.Fullscreencallback(switchtotype);
    }
    this.Fullscreencallback = function (switchtotype){
    }
    
    this.getSmallpopupwidth = function (){//全屏与缩小界面切换比例
        return parseInt(CrmPopup.getClientWidth()*0.7);
    }
    
    this.getBigpopupwidth = function (){
        var popupobj = CrmPopup.getPopupObj("last");
        if(popupobj.homestuffchuantou != undefined && popupobj.homestuffchuantou=='yes'){//wym 231220 BUG0077444 首页穿透到列表时，全屏修改为全屏展示
            return parseInt(CrmPopup.getClientWidth());
        }
        return parseInt(CrmPopup.getClientWidth()*0.9);
    }
    //duan 20240710 详情页刷新头部方法,留着空的重写
    this.refreshDetailHead=function (){}
    this.getSearch = function () {

    }

    //获取弹出框内容高度,默认显示最大内容高度显示80%
    this.proportion=0.8;
    this.getPopContentHeight = function ( ){
        var windowheight = ld(window).height();
        if(this.proportion){
            windowheight = windowheight*this.proportion;
        }
        var popHeadHeight = 0;
        if(ld('#'+this.divid + " #" + this.divid + '_head').length > 0){
            popHeadHeight = parseInt(ld('#'+this.divid + " #" + this.divid + '_head').outerHeight());
        }
        var popFootHeight = 0;
        if(ld('#'+this.divid + " #" + this.divid + '_popupbottom').length > 0){
            popFootHeight = parseInt(ld('#'+this.divid + " #" + this.divid + '_popupbottom').outerHeight());
        }
        else if(ld('#'+this.divid + ' .E_pbtn').length > 0){
            popFootHeight = parseInt(ld('#'+this.divid + ' .E_pbtn').outerHeight());
        }
        var contentHeight = parseInt(windowheight - popHeadHeight - popFootHeight);
        return contentHeight;
    }

    // 设置内容最大高度
    this.popBodyObj = '';
    this.reduceBodyHeight = 0;// 需要去掉的给高度
    this.setPopBodyObj = function(bodytmpobj){
        this.popBodyObj = ld('#'+this.divid).find(bodytmpobj);
    }
    this.setPopBodyMaxHeight = function(bodytmpobj){
        this.setPopBodyObj(bodytmpobj);
        this.popBodyObj.css('max-height',this.getPopContentHeight()-this.reduceBodyHeight+'px');
        this.center();
    }

}

CrmPopup.Cancel = function (Cancelfun, cancelparamobj) {
    cancelparamobj['button'] = this;
    Cancelfun.call(this, cancelparamobj);
}
CrmPopup.isPopup = function () {
    if (CrmPopup.global_listPopupObj.length > 0 && CrmPopup.global_listPopupObj[0] != undefined) {
        return true;
    }
    return false;
}
CrmPopup.zIndex = 1100;
CrmPopup.global_listPopupObj = [];
CrmPopup.findHtmlobj = function (divid, name) {
    var mutlpicklistobj = ld("#" + divid + " [name='" + name + "[]']");
    if (mutlpicklistobj != undefined && mutlpicklistobj.length > 0) {
        //多选框
        return mutlpicklistobj;
    }
    return ld("#" + divid + " [name='" + name + "']");
}
CrmPopup.isExistsObj = function (divid, name) {

    if (ld("#" + divid + " [name='" + name + "']") != undefined && ld("#" + divid + " [name='" + name + "']").length > 0) {
        return true;
    }
    if (ld("#" + divid + " [name='" + name + "[]']") != undefined && ld("#" + divid + " [name='" + name + "[]']").length > 0) {
        //多选框
        return true;
    }
    return false;
}
CrmPopup.setHtmlobjval = function (divid, name, value) {
    if (ld("#" + divid + " [name='" + name + "']").attr("type") == 'text' || ld("#" + divid + " [name='" + name + "']").attr("type") == 'hidden') ld("#" + divid + " [name=" + name + "]").val(value);
}
CrmPopup.getHtmlobjval = function (divid, name) {

    var tagname = ld("#" + divid + " [name='" + name + "']").prop("tagName");


    if (tagname == undefined) {
        //下拉框 多选
        if (ld("#" + divid + " [id=" + name + "]").attr("multiple") != undefined && ld("#" + divid + " [id=" + name + "]").attr("multiple") == 'multiple' && ld("#" + divid + " [id=" + name + "]").prop("tagName") == 'SELECT') {
            return ld("#" + divid + " [id=" + name + "]").val();
        } else {
            return '';
        }
    }
    if (ld("#" + divid + " [name=" + name + "]").attr("type") == 'text' || ld("#" + divid + " [name=" + name + "]").attr("type") == 'hidden') {
        return trim(ld("#" + divid + " [name=" + name + "]").val());
    } else if (ld("#" + divid + " [name=" + name + "]").attr("type") == 'checkbox') {
        if (ld("#" + divid + " [name=" + name + "]").prop("checked")) {
            return 1;
        } else {
            return 0;
        }
    } else if (ld("#" + divid + " [name=" + name + "]").attr("type") == 'select' || (tagname != undefined && tagname.toLowerCase() == 'select')) {
        return ld("#" + divid + " [name=" + name + "] option:selected").val();

    } else if (tagname.toLowerCase() == 'textarea') {

        return ld("#" + divid + " [name=" + name + "]").val();
    } else if (tagname.toLowerCase() == 'span') {
        return ld("#" + divid + " [name=" + name + "]").html();
    } else if (ld("#" + divid + " [name=" + name + "]").attr("type") == undefined) {
        //日期文本框

        return ld("#" + divid + " [name=" + name + "]").val();
    }
    //33167: 日程管理单据查看明细界面：小编辑修改字段值，保存，结果没有保存成功
    return "";

}
CrmPopup.getPopupObjByDivId = function (divid) {
    var len = CrmPopup.global_listPopupObj.length;
    for (i = len - 1; i >= 0; i--) {
        var obj = CrmPopup.global_listPopupObj[i];
        if (obj.divid != undefined && divid) {
            return obj;
        }
    }
}
//pagetype="create_edit_modulepage";//获取最后一个编辑或新增的弹出层界面
CrmPopup.getlastPopupObjByPageType = function (pagetype) {
    var len = CrmPopup.global_listPopupObj.length;
    for (i = len - 1; i >= 0; i--) {
        var obj = CrmPopup.global_listPopupObj[i];
        if (obj.pagetype != undefined && obj.pagetype == pagetype) {
            return obj;
        }
    }

}
CrmPopup.getlastPopupObjByType = function (type) {
    var len = CrmPopup.global_listPopupObj.length;
    for (i = len - 1; i >= 0; i--) {
        var obj = CrmPopup.global_listPopupObj[i];
        if (obj.type != undefined && obj.type == type) {
            return obj;
        }
    }

}
CrmPopup.getPopupObj = function (index) {
    //最新的弹出层
    if (isNaN(index) && index.toLowerCase() == 'last') {
        return CrmPopup.global_listPopupObj[CrmPopup.global_listPopupObj.length - 1];
    }
    //最新弹出层的前一个弹出层
    if (isNaN(index) && index.toLowerCase() == 'lastprev') {
        if (CrmPopup.global_listPopupObj.length >= 2) return CrmPopup.global_listPopupObj[CrmPopup.global_listPopupObj.length - 2]; else return undefined;
    } else if (isNaN(index) && index.toLowerCase() == 'first') {
        //第一个弹出层，例如模块序时簿
        return CrmPopup.global_listPopupObj[0];
    }
    if (CrmPopup.global_listPopupObj.length > index) {
        return CrmPopup.global_listPopupObj[index];
    }
    return undefined;
}
CrmPopup.delPopupobjByType = function (type) {
    for (var i = 0; i < CrmPopup.global_listPopupObj.length; i++) {
        if (CrmPopup.global_listPopupObj[i].type == type) {
            CrmPopup.global_listPopupObj.splice(i, 1);
            break;
        }
    }
}
/**
 删除字符串两边的单引号
 **/
CrmPopup.deletequotation = function (str) {

    if (trim(str).indexOf("'") == 0) {
        str = str.substr(1, str.length - 1);
    }

    if (trim(str).indexOf("'") >= str.length - 1) {
        str = str.substr(0, str.length - 1);
    }
    return str;

}

CrmPopup.load = function (headtitle, Okfun, Cancelfun, cssWidth, module, OkfunParamObj, OkText, CancelfunParamObj, CancelText) {

    var crmpopupobj = new CrmPopup();

    crmpopupobj.setParams(headtitle, Okfun, Cancelfun, cssWidth, module, OkfunParamObj, OkText, CancelfunParamObj, CancelText);
    return crmpopupobj;

}

CrmPopup.global_signleInstance = [];
//弹出层的单例
CrmPopup.getInstance = function (type, headtitle, Okfun, Cancelfun, cssWidth, module, OkfunParamObj, OkText, CancelfunParamObj, CancelText) {
    for (var i = 0; i < CrmPopup.global_signleInstance.length; i++) {
        if (CrmPopup.global_signleInstance[i].type == type) {
            return CrmPopup.global_signleInstance[i];
        }
    }

    var crmpopupobj = new CrmPopup();
    crmpopupobj.setParams(headtitle, Okfun, Cancelfun, cssWidth, module, OkfunParamObj, OkText, CancelfunParamObj, CancelText);
    crmpopupobj.type = type;
    CrmPopup.global_signleInstance.push(crmpopupobj);
    return crmpopupobj;

}

CrmPopup.rightCenter = function (obj, popupobj) {

    var windowWidth = document.documentElement.clientWidth;

    var windowHeight = CrmPopup.getClientHeight();

    var popupHeight = ld(obj).height();
    var popupWidth = ld(obj).width();

    var popupmaxheight = popupobj.getpopupMaxHeight();
    
    var positions_right_px = (popupobj.positions_right_px && !empty(popupobj.positions_right_px))?popupobj.positions_right_px:0;

    if (popupmaxheight > 0) {


        ld(obj).css({
            "position": "fixed", //"transition":"1s max-height",
            "max-height": popupmaxheight,
            "height": popupmaxheight,
            "width": popupWidth,
            "top": (windowHeight - popupmaxheight) / 2,   //+ld(document).scrollTop()明细界面的相关信息，滚动条到最下面，则弹出层显示错误
            "right": positions_right_px

        });


        popupobj.setScrollDivMaxHeight();
    } else {
        ld(obj).css({
            //"transition":"1s max-height",
            "position": "fixed",

            "width": popupWidth, "top": (windowHeight - popupHeight) / 2,   //+ld(document).scrollTop()明细界面的相关信息，滚动条到最下面，则弹出层显示错误
            "right": positions_right_px

        });
    }


}
CrmPopup.right = function (obj, popupobj) {
    var windowWidth = document.documentElement.clientWidth;
    var windowHeight = document.documentElement.clientHeight;
    var popupHeight = ld(obj).height();
    var popupWidth = ld(obj).width();
    var positions_right_px = (popupobj.positions_right_px && !empty(popupobj.positions_right_px))?popupobj.positions_right_px:0;

    ld(obj).css({
        "max-height": popupobj.getpopupMaxHeight(), "height": popupobj.getpopupMaxHeight(), "width": 0, "top": 0,   //+ld(document).scrollTop()明细界面的相关信息，滚动条到最下面，则弹出层显示错误
        "right": positions_right_px
    });
    ld(obj).animate({width: popupWidth}, 400, function () {
        //明细界面推进内容宽度
        if (typeof DetailViewPage != undefined && popupobj.pagetype == DetailViewPage.pagetype) {
            var width = ld("#" + ld(obj).attr("id")).width();
            ld("#" + ld(obj).attr("id") + " .multi-step .modal-header").css("width", width - 10 + "px");
        }
        popupobj.isfinishanimate='yes';
        popupobj.PopupAllReadFun();
    });
    ld(obj).css({
        "position": "fixed",
    });
}
CrmPopup.getClientWidth = function () {
    var windowWidth = document.documentElement.clientWidth;
    return windowWidth;
}
CrmPopup.getClientHeight = function () {
    return document.documentElement.clientHeight;
}
//zxm 2021-0823 全屏显示
CrmPopup.fullScreen = function (obj, popupobj) {
    var windowHeight = CrmPopup.getClientHeight();
    var windowWidth = CrmPopup.getClientWidth();
    ld(obj).css({
        "position": "fixed",
        "min-height": windowHeight,
        "height": windowHeight,
        "width": windowWidth,
        "top": 0,
        "right": 0
    });
    var headHeight = parseInt(ld('#' + popupobj.divid + '_head').outerHeight());
    var bottomHeight = parseInt(ld('#' + popupobj.divid + '_popupbottom').outerHeight());
    ld('#' + popupobj.divid + '_scroll').css({
        'height': '100%', 'max-height': 'calc(100% - '+(headHeight+bottomHeight)+'px)'
    });
}
//zxm 20230818 高度全屏 宽度自适应  bottomHeight--底部的高度
CrmPopup.fullHeight = function (obj, popupobj,bottomHeight) {
    var windowHeight = CrmPopup.getClientHeight();
    ld(obj).css({
        "position": "fixed",
        "min-height": windowHeight,
        "height": windowHeight,
        "top": 0
    });
    ld('#' + popupobj.divid + '_scroll').css({
        'height': '100%', 'max-height': 'calc(100% - '+parseInt(bottomHeight)+'px)'
    });
}
CrmPopup.verticalCenter = function (obj, popupobj) {
    var windowHeight = CrmPopup.getClientHeight();
    var popupHeight = ld(obj).height();
    var popupmaxheight;
    if (popupobj != undefined && typeof popupobj.getpopupMaxHeight != "undefined") var popupmaxheight = popupobj.getpopupMaxHeight();
    if (popupmaxheight > 0) {
        var tmpheight = Math.min(popupmaxheight, popupHeight);
        ld(obj).css({
            "position": "fixed", "max-height": popupmaxheight,
            "top": (windowHeight - popupHeight) / 2   //+ld(document).scrollTop()明细界面的相关信息，滚动条到最下面，则弹出层显示错误
        });
        popupobj.setScrollDivMaxHeight();

    } else {

        ld(obj).css({
            "position": "fixed",
            "top": (windowHeight - popupHeight) / 2   //+ld(document).scrollTop()明细界面的相关信息，滚动条到最下面，则弹出层显示错误
        });
    }
}
CrmPopup.center = function (obj, popupobj) {
    var windowWidth = CrmPopup.getClientWidth();
    var windowHeight = CrmPopup.getClientHeight();
    var popupHeight = ld(obj).height();
    var popupWidth = ld(obj).width();
    var popupmaxheight;
    if (popupobj != undefined && typeof popupobj.getpopupMaxHeight != "undefined") var popupmaxheight = popupobj.getpopupMaxHeight();
    if (popupmaxheight > 0) {
        var tmpheight = Math.min(popupmaxheight, popupHeight);
        ld(obj).css({
            "position": "fixed", "max-height": popupmaxheight,

            "top": (windowHeight - popupHeight) / 2,   //+ld(document).scrollTop()明细界面的相关信息，滚动条到最下面，则弹出层显示错误
            "left": (windowWidth - popupWidth) / 2
        });
        popupobj.setScrollDivMaxHeight();

    } else {

        ld(obj).css({
            "position": "fixed",

            "top": (windowHeight - popupHeight) / 2,   //+ld(document).scrollTop()明细界面的相关信息，滚动条到最下面，则弹出层显示错误
            "left": (windowWidth - popupWidth) / 2
        });
    }
}
CrmPopup.showHideExistsHtml = function (name) {

    var popupobj = CrmPopup.getPopupObj("last");
    var divid = popupobj.divid;
    var obj = CrmPopup.findHtmlobj(divid, name);

    var tmpobj = new Object();
    tmpobj.divid = name;
    CrmPopup.global_listPopupObj.push(tmpobj);

    if (obj.css("display") == "none") {
        var tmplayer = new CrmPopupLayer(tmpobj);
        tmpobj.layerobj = tmplayer;

        CrmPopup.zIndex = CrmPopup.zIndex + 3;
        // alert(CrmPopup.zIndex);
        //  obj.css("z-index",CrmPopup.zIndex);
        obj.css("display", "block");
        tmplayer.block();
        // CrmPopup.center(obj);
    } else {
        obj.css("display", "none");
        CrmPopup.zIndex--;
    }
}
/**
 以jquery方式加载ajax内容，这个可以吧ajax内容的js文件和函数加载
 **/
CrmPopup.setPopupobjHtmlContent_scroll_jquery = function (popupobj, html) {

    popupobj.createScrollDiv();//创建滚动条
    popupobj.setInnerHtml = function () {
        if (popupobj.scrolldiv != "") {
            ld("#" + popupobj.divid).html(popupobj.popupheadhtml + popupobj.scrolldiv + popupobj.htmlcontent + "</div>" + popupobj.popupbottomhtml);
        } else ld("#" + popupobj.divid).html(popupobj.popupheadhtml + popupobj.htmlcontent + popupobj.popupbottomhtml);
        document.getElementById(popupobj.divid).style.display = "block";
    }

    popupobj.show(html);
    popupobj.setScrollDivMaxHeight();
    popupobj.center();
    if (typeof cls_wxOpenDataobj != undefined && typeof cls_wxOpenDataobj != "undefined") {
        //通讯录(pc端企业微信)
        cls_wxOpenDataobj.bindAllOpenDataByPopupObj(popupobj);
    }

}

CrmPopup.setPopupobjHtmlscrolljquery_noposition = function (popupobj, html) {

    popupobj.createScrollDiv();//创建滚动条
    popupobj.setInnerHtml = function () {
        if (popupobj.scrolldiv != "") {
            ld("#" + popupobj.divid).html(popupobj.popupheadhtml + popupobj.scrolldiv + popupobj.htmlcontent + "</div>" + popupobj.popupbottomhtml);
        } else ld("#" + popupobj.divid).html(popupobj.popupheadhtml + popupobj.htmlcontent + popupobj.popupbottomhtml);
        document.getElementById(popupobj.divid).style.display = "block";
    }

    popupobj.show(html);
    popupobj.setScrollDivMaxHeight();

    if (typeof cls_wxOpenDataobj != undefined && typeof cls_wxOpenDataobj != "undefined") {
        //通讯录(pc端企业微信)
        cls_wxOpenDataobj.bindAllOpenDataByPopupObj(popupobj);
    }

}
//带滚动显示弹出层
CrmPopup.setPopupobjHtmlContent_scroll = function (popupobj, html) {
    popupobj.createScrollDiv();//创建滚动条
    popupobj.show(html);
    popupobj.setScrollDivMaxHeight();
    popupobj.center();
}


//带滚动显示弹出层
CrmPopup.setPopupobjHtmlContent_scrollbyPosition = function (popupobj, html) {
    popupobj.createScrollDiv();//创建滚动条
    popupobj.show(html);
    popupobj.setScrollDivMaxHeight();

    if (popupobj.position == CrmPopup.Positions.rightcenter) {

        popupobj.rightCenter();
    } else popupobj.center();
}
CrmPopup.Positions = {
    left: 2, right: 3, center: 4, rightcenter: 5,
}
CrmPopup.start_progressObjs = [];

//wym 231205 XUQIU1002278 弹窗统一宽度
CrmPopup.getSmallpopupwidth = function (){//全屏与缩小界面切换比例
    return parseInt(CrmPopup.getClientWidth()*0.7);
}
//wym 231205 XUQIU1002278 弹窗统一宽度
CrmPopup.getBigpopupwidth = function (){
    var popupobj = CrmPopup.getPopupObj("last");
    if(popupobj.homestuffchuantou != undefined && popupobj.homestuffchuantou=='yes'){//wym 231220 BUG0077444 首页穿透到列表时，全屏修改为全屏展示
        return parseInt(CrmPopup.getClientWidth());
    }
    return parseInt(CrmPopup.getClientWidth()*0.9);
}