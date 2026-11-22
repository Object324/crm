function cls_relationshipChart(frommodule,fromrecord,chartmodule) {
    // 设置为只读
    Object.defineProperty(this, 'frommodule', {
        value: frommodule,
        writable: false,  // 不可修改
        configurable: false // 不可删除或重新定义
    });
    Object.defineProperty(this, 'fromrecord', {
        value: fromrecord,
        writable: false,
        configurable: false
    });
    Object.defineProperty(this, 'chartmodule', {//图谱数据的模块
        value: chartmodule,
        writable: false,
        configurable: false
    });
    this.divobj = '';
    this.divid = '';
    this.popupobj = '';
    this.dragBtnStatus = 'no';//拖动是否启用
    this.drag = false;//是否正在拖动
    this.translateX = 0;
    this.translateX = 0;
    this.scaleValue = 1;
    this.editBtnToolTip = false;//是否显示锁定状态下的编辑按钮tooltip
    this.reszieStatus = false;
    this.refreshStatus = false;
    this.setShowFieldHtml = '<a href="javascript:;" id="showfieldset" style="float: right;">' + arrJsPopLabel['SETMAPDISPLAYFIED'] + '</a>';
    this.relationshipChartHtml = '';
    this.tagSetPopupobj = '';//标签弹窗obj
    this.lastClickNodeobj = '';//最后一个点击的节点的jquery对象，用于标签设置的记住选中节点
    this.AccountsChartUrl = '';//客户图谱 选择客户的固定url
    this.relatedid = '';//相关信息id

    //后台请求的数据
    this.is_admin = '';//是否是管理员
    this.maxnodeid = '';//最大节点nodeid
    this.showtype = '';//界面 相关信息显示/全屏/编辑
    this.lockstatus = '';//图谱锁定状态
    this.arrFixedLabelArr = {};//翻译
    this.leftListDataArr = {};//左侧单据的全部数据内容
    this.relatedRecordsArr = [];//所有相关客户的单据id
    this.relationshipChartDataArr = {};//图谱节点数据
    this.showFieldInfoArr = {};//显示字段的属性数据
    this.tagDataByRecordArr = {};//所有相关单据的标签数据
    this.hrefColumnname = '';//超链接字段columnname
    this.haveRecordNodeArr = {};//节点和单据关系
    this.repeatRecordArr = {};//重复单据和节点关系
    this.repeatNodeid = '';//定位 记住重复的节点nodeid
    this.haveTagField = '';//是否有标签字段

    var that = this;


    //设置弹窗obj
    this.setPopupObj = function (popupobj){
        // that.popupobj = popupobj;
        // that.divid = that.popupobj.divid;
        // that.divobj = ld('#'+that.popupobj.divid);

        // 设置为只读
        Object.defineProperty(this, 'popupobj', {
            value: popupobj,
            writable: false,  // 不可修改
            configurable: false // 不可删除或重新定义
        });
        Object.defineProperty(this, 'divid', {
            value: popupobj.divid,
            writable: false,
            configurable: false
        });
        Object.defineProperty(this, 'divobj', {
            value: ld('#'+that.popupobj.divid),
            writable: false,
            configurable: false
        });
    }

    //设置数据
    this.setParams = function(paramobj){
        //赋值变量
        ld.each(paramobj,function (key,value) {
            if (that.hasOwnProperty(key) && typeof that[key] !== 'function' && !empty(value)) {
                that[key] = value;
            }
        });
        // console.log(that);
    }

    //显示图谱全部界面
    this.showRelationshipChart = function (){
        if (!that.refreshStatus){//初次显示才进入
            that.resize();
            that.setCommonEvent();
            that.refreshStatus = true;
        }
        that.showRelationshipChartData();
        if (that.showtype == 'edit' || this.showtype == 'fullscreen'){//编辑/全屏界面 显示左侧列表
            that.showLeftListData();
        }
    }

    //调整宽度和高度
    this.resize = function (){
        if (that.showtype == 'view'){//相关信息查看界面
            var width=parseInt((CrmPopup.getClientWidth()-getLeftMenuWidth())*0.9)-16;
            that.divobj.find('#relationshipChartPopupDiv').css('width',width);

            var height = CrmPopup.getClientHeight();
            height -= that.divobj.find('#'+that.divid+'_head').outerHeight(true);//头部
            height -= that.divobj.find('[name=relatelisttab]').outerHeight(true);//相关信息
            var keyFieldHeight = that.divobj.find('#related_keywords_field').outerHeight(true);
            if (keyFieldHeight > 0){
                keyFieldHeight += 10;//关键信息底部的padding
                height -= keyFieldHeight;//关键信息栏
            }
            height -= that.divobj.find('#relationshipChartRightBtnDiv').outerHeight(true);//放大缩小按钮
            if (that.divobj.find('#relationshipChartTip').length > 0){
                height -= that.divobj.find('#relationshipChartTip').outerHeight(true);//放大缩小按钮
            }
            height -= 20;//弹窗中间部分padding
            that.divobj.find('#relationshipChartDiv').css('height',height);
        }else {//全屏和编辑界面
            that.popupobj.proportion = 1;
            var height = that.popupobj.getPopContentHeight();
            //列表
            var leftListHeight = height - that.divobj.find('#relationshipChartLeftHeadDiv').outerHeight(true);//右上角部分
            leftListHeight = leftListHeight - that.divobj.find('#LeftListTip').outerHeight(true);//列表上方提示部分
            that.divobj.find('#LeftListDiv').css('height',leftListHeight - 20);//20是图谱横向滚动条17+3
            //图谱
            that.divobj.find('#relationshipChartPopupDiv').css('width',CrmPopup.getClientWidth());
            that.divobj.find('#relationshipChartPopupDiv').css('height',height);
            var chartheight = height - that.divobj.find('#relationshipChartRightBtnDiv').outerHeight(true);//放大缩小按钮
            that.divobj.find('#relationshipChartDiv').css('height',chartheight - 3);//和左边列表底部一致
            if (!empty(that.tagSetPopupobj)){
                var tagSetPopupheight = that.tagSetPopupobj.getPopContentHeight();
                ld('#'+that.tagSetPopupobj.divid).find('#setTagDiv').css('height',tagSetPopupheight+'px');
                ld('#'+that.tagSetPopupobj.divid).css('top','0px');
                ld('#'+that.tagSetPopupobj.divid).css('right','0px');
            }
        }
    }

    //设置非列表和图谱部分的事件
    this.setCommonEvent = function (){
        //放大缩小恢复拖动
        that.divobj.find('[tag=changeRelationshipChart]').off('click').on('click',function () {
            that.changeRelationshipChart(ld(this).data('changetype'));
        });
        //tooltip悬浮
        tooltip(that.divobj.find('.ChartToolTip'),{transition: true, time: 200});
        if (that.lockstatus == 'yes'){//图谱锁定
            that.editBtnToolTip = true;
            tooltip('.editBtnToolTip',{transition: true, time: 200});
        }
        if (that.is_admin && that.showtype == 'edit' && that.divobj.find('#showfieldset').length == 0){//设置显示字段按钮
            that.divobj.find('#'+that.divid+'_imgclose').before(that.setShowFieldHtml);
            that.divobj.find('#showfieldset').off('click').on('click',function () {
                that.showFieldSet();
            });
        }

        if (that.showtype == 'view'){//相关信息查看界面 全屏界面
            //编辑
            that.divobj.find('#editBtn').off('click').on('click',function () {
                that.editRelationshipChart();
            });
            //全屏
            that.divobj.find('#FullScreenBtn').off('click').on('click',function () {
                that.fullScreen();
            });
            //锁定
            that.divobj.find('#lockBtn').off('click').on('click',function () {
                that.changeLockStatus();
            });
            if (!that.reszieStatus){
                /*ld(window).resize(function () {
                    var popupobj = CrmPopup.getPopupObj('last');
                    if (ld('#relationshipChartPopupDiv').length > 0 && !empty(popupobj.relationshipChartobj)){
                        popupobj.relationshipChartobj.resize();
                    }
                });*/
                that.reszieStatus = true;
            }

        }else if (that.showtype == 'edit'){//编辑界面
            if (that.frommodule == 'Accounts' && that.chartmodule == 'Accounts'){//客户-相关信息-客户图谱
                //按照"上级单位生成图谱"
                that.divobj.find('#generate').off('click').on('click',function () {
                    that.getRelationshipChartByParentid();
                });
                //选择相关客户
                that.divobj.find('#selectRelatedRecord').off('click').on('click',function () {
                    that.selectRelatedRecord();
                });
            }


        }
    }

    //编辑按钮
    this.editRelationshipChart = function (){
        if (that.lockstatus == 'yes'){//锁定状态不能编辑
            return false;
        }
        var url = 'index.php?module='+that.frommodule+'&action='+that.frommodule+'Ajax&file=relationshipChart';
        url += '&frommodule='+that.frommodule+'&fromrecord='+that.fromrecord+'&chartmodule='+that.chartmodule;
        url += '&mode=editChart';
        ldAjax(url,'',function (data) {
            if (data.code == 1){
                var popupobj = CrmPopup.load(data.result.title,'','',CrmPopup.getClientWidth(),data.result.frommodule,'',data.result.oktext,'',data.result.canceltext);
                popupobj.show(data.result.content);
                var cls_relationshipChartobj = new cls_relationshipChart(data.result.frommodule,data.result.fromrecord,data.result.chartmodule);
                cls_relationshipChartobj.setPopupObj(popupobj);
                cls_relationshipChartobj.setParams(data.result);
                cls_relationshipChartobj.showRelationshipChart();
                popupobj.relationshipChartobj = cls_relationshipChartobj;
                popupobj.center();
                popupobj.type = 'relationshipChartPopup';
                cls_relationshipChartobj.divobj.find('#'+cls_relationshipChartobj.divid+'_btnok').off('click').on('click',function () {
                    cls_relationshipChartobj.saveRelationshipChart();
                })
                cls_relationshipChartobj.divobj.find('#'+cls_relationshipChartobj.divid+'_btncancel').off('click').on('click',function () {
                    if (!empty(cls_relationshipChartobj.tagSetPopupobj)){//关闭标签弹窗
                        ld('#'+cls_relationshipChartobj.tagSetPopupobj.divid+'_imgclose').click();
                    }
                })
                DelProgressObjs();
            }
        });
    }

    //保存图谱
    this.saveRelationshipChart = function (){
        //判断是否有重复对象
        if (!empty(that.repeatRecordArr)){
            MessagePopup.TipOne_warning(that.arrFixedLabelArr.RepeatCustomersSaveTip);
            return false;
        }
        var url = 'index.php?module='+that.frommodule+'&action='+that.frommodule+'Ajax&file=relationshipChart';
        url += '&frommodule='+that.frommodule+'&fromrecord='+that.fromrecord+'&chartmodule='+that.chartmodule;
        url += '&mode=saveChart';
        var haveNodeRecords = Object.values(that.haveRecordNodeArr).join(',');
        var params = {'relationshipChartDataArr':JSON.stringify(that.relationshipChartDataArr),'haveNodeRecords':haveNodeRecords,'relatedRecords':that.relatedRecordsArr.join(',')};
        ldAjax(url,params,function (data) {
            if (data.code == 1){
                if (!empty(that.tagSetPopupobj)){//关闭标签弹窗
                    ld('#'+that.tagSetPopupobj.divid+'_imgclose').click();
                }
                that.popupobj.CancelEvent();
                var DetailPopupObj = CrmPopup.getPopupObj('last');
                var relationshipobj = DetailPopupObj.relationshipChartobj;
                relationshipobj.setParams(data.result);
                relationshipobj.showRelationshipChart();
                if (data.result.showTipStatus == 'yes'){
                    relationshipobj.divobj.find('#relationshipChartTip').css('display','');
                }else {
                    relationshipobj.divobj.find('#relationshipChartTip').css('display','none');
                }
                DelProgressObjs();
            }else {
                DelProgressObjs();
                MessagePopup.TipOne_warning(data.msg);
            }

        })
    }

    //显示左侧列表部分
    this.showLeftListData = function (){
        var leftListDataArr = that.leftListDataArr;
        var hrefColumnname = that.hrefColumnname;
        var haveRecordNodeArr = that.haveRecordNodeArr;
        var records = Object.values(haveRecordNodeArr);//右侧图谱的单据id
        var nochosehtml = '';
        var chosedhtml = '';
        ld.each(leftListDataArr,function (record,info) {
            var hrefContent = info[hrefColumnname];
            var havepermittedtoview = info.havepermittedtoview;
            if (havepermittedtoview == 'yes' && records.indexOf(record) == -1){
                if (record != that.fromrecord){//单据id是否是当前客户
                    var deleteListHtml = '<i class="ld-fonticon ld-fonticon-close" style="padding-left: 5px;display: none" tag="deleteRecord" data-record="'+record+'"></i>'
                }else {
                    var deleteListHtml = '';
                }
                nochosehtml += '<li class="drag-handle leftListDataLi" tag="selectableList" data-record="'+record+'">'+hrefContent+deleteListHtml+'</li>'
            }
            else{
                chosedhtml += '<li class="drag-handle leftListDataLi chosen" style="" data-record="'+record+'">'+hrefContent+'</li>'
            }
        });
        var html = '';
        if(!empty(nochosehtml)){
            html += '<ul id="data_list_ul" style="padding:0 16px;">'+nochosehtml+'</ul>';
        }
        if(!empty(chosedhtml)){
            html += '<ul style="padding:0 16px;">'+chosedhtml+'</ul>';
        }
        that.divobj.find('#LeftListDiv').html(html);

        if (that.showtype == 'edit'){//绑定左侧列表的事件
            that.setLeftListEvent();
        }
    }

    //显示右侧图谱部分
    this.showRelationshipChartData = function (){
        //显示
        that.relationshipChartHtml = '';
        that.getrelationshipChartHtml(0,that.relationshipChartDataArr);
        var relationshipChartDivobj = that.divobj.find('#relationshipChartDiv #node_wrap_div');
        relationshipChartDivobj.html(that.relationshipChartHtml);
        tooltip(that.divobj.find('[name=title]'),{transition: true, time: 200});

        if (that.showtype == 'edit'){//绑定图谱的事件
            that.setRelationshipChartEvent();
            that.getRepeatNode();

        }
    }

    //组图谱全部html
    this.getrelationshipChartHtml = function (parentnodeid,relationshipChartDataArr){
        if(parentnodeid == undefined || parseInt(parentnodeid) < 0){
            return '';
        }
        var childrennodeid_arr = that.getChildrenNodeidInfo(parentnodeid,relationshipChartDataArr);
        if (childrennodeid_arr.length > 0) {
            if(parentnodeid !=0){
                that.relationshipChartHtml += '<div class="branch-box-wrap">'+
                    '<div class="branch-box">';
            }
            for (var i=0;i<childrennodeid_arr.length;i++) {
                that.relationshipChartHtml += '<div id="colbox_'+parentnodeid+'" class="col-box">';
                that.relationshipChartHtml += that.getChartNodeHtml(parentnodeid,childrennodeid_arr,i);
                that.getrelationshipChartHtml(childrennodeid_arr[i].nodeid, relationshipChartDataArr);
                that.relationshipChartHtml += '</div>';
            }
            if(parentnodeid != 0 ){
                that.relationshipChartHtml += '</div></div>';
            }
        }
    }

    //获取下级节点的数据
    this.getChildrenNodeidInfo=function(parentnodeid,relationshipChartDataArr) {
        var newArr= [];
        if (parentnodeid == 0){
            ld.each(relationshipChartDataArr,function (index,info) {
                if (parseInt(info.parentnodeid) == parseInt(parentnodeid)){
                    newArr.push(info);
                    return newArr;
                }
            });
        }else {
            var childrennodeid = relationshipChartDataArr[parentnodeid].childrennodeid;
            if (!empty(childrennodeid)){
                ld.each(childrennodeid.toString().split(','),function (index,nodeid){
                    if (!empty(nodeid)){
                        newArr.push(relationshipChartDataArr[nodeid]);
                    }
                });
            }
        }
        return newArr;
    }

    //单个节点html
    this.getChartNodeHtml = function (parentnodeid,childrennodeid_arr,index){
        var html='';
        var childnodeidinfo = childrennodeid_arr[index];
        var nodeid = childnodeidinfo.nodeid;
        var chartrecord = childnodeidinfo.chartrecord;
        if(index == 0 && childnodeidinfo.parentnodeid !=0){
            //下级节点中最左边节点添加，不显示左边横线
            html += '<div class="top-left-cover-line" tag="line"></div>';
        }
        html +='<div class="condition-node-box" tag="nodebox" data-nodeid="'+nodeid+'" data-parentnodeid="'+parentnodeid+'">';
        var content_tag = (chartrecord != 0 && !empty(chartrecord) && !empty(that.leftListDataArr[chartrecord]))?'':'sortable="yes"';
        content_tag += ' tag="tagClick" ';
        if(childnodeidinfo.parentnodeid == 0){
            html +='<div data-nodeid="'+nodeid+'" data-parentnodeid="'+parentnodeid+'" id="node_box_'+nodeid+'" class="node-wrap-box node-wrap-box-first" '+content_tag+'>';
        }
        else{
            html +='<div class="line" tag="line"></div>';//有上级节点显示线
            html +='<div data-nodeid="'+nodeid+'" data-parentnodeid="'+parentnodeid+'" id="node_box_'+nodeid+'" class="node-wrap-box" '+content_tag+'>';
        }
        //内容
        var content = that.getShowContent(chartrecord);
        html += '<div class="node-box-item">';
        html += '<div class="title" id="title_'+nodeid+'" name="title" style="padding: 0 25px 0 20px;">' + that.getShowTitle(chartrecord) + '</div>';
        html += '<div class="content" name="content" id="content_' + nodeid + '" data-nodeid="'+nodeid+'">' + content + '</div>';
        //节点各种按钮
        html += '<div class="operation" name="operation" data-nodeid="' + nodeid + '" id="operation_' + nodeid + '">';
        html += '<b data-type="addtop" id="addtop_' + nodeid + '" tag="nodeBtn" style="width: 20px;height: 20px;"  data-nodeid="' + nodeid + '" class="operation-items addtop"></b>';
        html += '<b data-type="addbottom" id="addbottom_' + nodeid + '" tag="nodeBtn" style="width: 20px;height: 20px;" data-nodeid="' + nodeid + '" class="operation-items addbottom"></b>';
        html += '<b data-type="addleft" id="addleft_' + nodeid + '" tag="nodeBtn" style="width: 20px;height: 20px;" data-nodeid="' + nodeid + '" class="operation-items addleft"></b>';
        html += '<b data-type="addright" id="addright_' + nodeid + '" tag="nodeBtn" style="width: 20px;height: 20px;" data-nodeid="' + nodeid + '" class="operation-items addright"></b>';
        html += '<b data-type="deletebox" id="deletebox_' + nodeid + '" tag="nodeBtn" style="width: 20px;height: 20px;" data-nodeid="' + nodeid + '" class="operation-items ld-fonticon ld-fonticon-del"></b>';
        html += '</div>';
        html += '</div>';
        html += '</div>';

        if(childnodeidinfo.childrennodeid != ''){
            //有下级节点显示线
            html += '<div class="line"></div>';
        }
        html += '</div>';

        if(index == childrennodeid_arr.length-1 && childnodeidinfo.parentnodeid !=0){
            //下级节点中最右边节点添加，不显示右边横线
            html += '<div class="top-right-cover-line"></div>';
        }
        return html;
    }

    //获取节点显示的内容
    this.getShowContent = function (chartrecord){
        var content = '<span name="tobeadd" class="node-wrap-box-tobeadd">'+arrJsPopLabel['TOBEADD']+'</span>';
        if (chartrecord != '0' && !empty(chartrecord)){
            var leftListDataArr = that.leftListDataArr;
            var showFieldInfoArr = that.showFieldInfoArr;
            var chartrecordinfo = leftListDataArr[chartrecord];
            if (empty(chartrecordinfo)){
                return content;
            }
            var havepermittedtoview = chartrecordinfo.havepermittedtoview;
            if (havepermittedtoview == 'no'){//没有权限查看数据
                content = '<div name="tip" >'+that.arrFixedLabelArr.noPermittedToViewTip+'</div>';
            }else {
                content = '';
                ld.each(showFieldInfoArr,function (columnname,info) {
                    var columnname = info.columnname;
                    if (columnname != that.hrefColumnname){
                        var fieldlabel = info.fieldlabel;
                        var uitype = info.uitype;
                        var textColor = info.textColor;
                        var labelColor = info.labelColor;
                        var value = chartrecordinfo[columnname];
                        if (uitype == 301){
                            content += that.getTagContent(chartrecord);
                        }else {
                            if (empty(value)){
                                value =that.arrFixedLabelArr.empty;
                                content += '<div><span columnname="+columnname+">' + fieldlabel + ':&ensp;' + value + '</span></div>';
                            }else if (uitype == 15){
                                content += '<div><span columnname="+columnname+" style="color: '+textColor[value]+'">' + fieldlabel + ':&ensp;' + value + '</span></div>';
                            } else{
                                content += '<div><span columnname="+columnname+" style="color: '+textColor+'">' + fieldlabel + ':&ensp;' + value + '</span></div>';
                            }
                        }

                    }
                })
            }
            if(this.showtype == 'edit' && havepermittedtoview == 'yes'){
                content += '<div class="deleteinfo" id="deleteinfo" tag="deleteinfo"">' +
                    '<i tag="delete" class="ld-fonticon ld-fonticon-del" href="javascript:;" border="0"></i>' +
                    '</div>';
            }
        }

        return content;
    }

    //节点title
    this.getShowTitle = function (chartrecord){
        var html = '';
        if (chartrecord != '0' && !empty(chartrecord) && !empty(that.leftListDataArr[chartrecord])){
            var havepermittedtoview = that.leftListDataArr[chartrecord].havepermittedtoview;
            if (havepermittedtoview == 'yes'){
                var hrefColumnname = that.hrefColumnname;
                var leftListDataArr = that.leftListDataArr;
                var chartrecordinfo = leftListDataArr[chartrecord];
                html = chartrecordinfo[hrefColumnname];
            }
        }
        return html;
    }

    //获取标签部分的html
    this.getTagContent = function (chartrecord){
        var content = '';
        if (chartrecord != '0' && !empty(chartrecord) && !empty(that.leftListDataArr[chartrecord]) ){
            var leftListDataArr = that.leftListDataArr;
            var showFieldInfoArr = that.showFieldInfoArr;
            var fieldlabel = showFieldInfoArr.tag.fieldlabel;
            var chartrecordinfo = leftListDataArr[chartrecord];
            var allTagDataByRecord = that.tagDataByRecordArr;
            var tagData = allTagDataByRecord[chartrecord];
            content += '<div name="tag" style="overflow: hidden " tagRecord="'+chartrecord+'"><span style="float: left;">' + fieldlabel + ':&ensp;</span>';
            if (empty(tagData)){
                content += '<span>'+that.arrFixedLabelArr.empty+'</span>'
            }else {
                content += '<span class="module_list_tagger_span" style="flex-wrap: wrap">';
                ld.each(tagData,function (tagid,taginfo){
                    var tag_text = taginfo.tag;
                    var tag_type = taginfo.tag_type;
                    content += '<span class="module-map-tagger-fm-button '+tag_type+'" tagid="'+tagid+'">'+tag_text+'</span>';
                });
                content += '</span>';
            }
            content += '</div>';
        }
        return content;
    }

    //左侧列表部分事件
    this.setLeftListEvent = function (){
        //拖拽
        that.setListDragEvent();

        //删除按钮事件
        that.setDeleteRecordEvent();


    }

    //右侧图谱部分事件
    this.setRelationshipChartEvent = function (){
        //图谱节点右侧按钮事件
        that.setChartNodeEvent();

        //重复节点
        that.divobj.find('#repeatBtn').off('click').on('click',function () {
            that.setRepeatNodeEvent();
        })

    }

    //左侧列表删除等事件
    this.setDeleteRecordEvent = function () {
        //悬浮
        that.divobj.find('[tag=selectableList]').hover(
            function () {
                ld(this).find('[tag=deleteRecord]').css('display','');
                },
            function () {
                ld(this).find('[tag=deleteRecord]').css('display','none');
            }
            )
        //删除按钮
        that.divobj.find('[tag=deleteRecord]').off('click').on('click',function (event) {
            var record = ld(this).data('record');
            delete that.leftListDataArr[record];
            var remove_index = that.relatedRecordsArr.indexOf(record);
            that.relatedRecordsArr.splice(remove_index,1);
            that.showLeftListData();
            event.stopPropagation();
        })

    }


    //列表拖动到节点事件
    this.setListDragEvent = function (){
        //拖入div绑定，拖动事件；
        ld.each(that.divobj.find("[sortable=yes]"),function(index,obj){
            Sortable.create(ld(obj).get(0), {
                group:{name: 'node',pull:false},
                animation: 150,
                sort:false,
                dropOnEmpty: true,
                onChoose: function (evt) {
                },
                onChange: function(evt) {
                    ld(evt.to).find('li').css('display','none');
                },
                onRemove: function(evt) {
                },
                onEnd: function (evt) {

                }
            });
        })

        var listobj = that.divobj.find('#data_list_ul').get(0);
        if (!empty(listobj)){
            Sortable.create(listobj, {
                group: {name: 'node',pull:'clone',put:false},
                animation: 150,
                sort:false,
                draggable:".drag-handle",
                onChoose: function (evt) {
                },
                onStart: function (evt) {
                },
                onChange: function (evt) {
                },
                // 结束拖拽
                onEnd: function (evt) {
                    var nodeobj = ld(evt.to);
                    var nodeid = nodeobj.data('nodeid');
                    if (empty(nodeid)){
                        return false;
                    }
                    that.getRelatedChart(evt);
                },
            });
            // document.body.ondrop = function (event) {
            //     event.preventDefault();
            //     event.stopPropagation();
            // };
        }
    }

    //获取拖拽客户的图谱
    this.getRelatedChart = function (evt){
        var itemobj = ld(evt.item);
        var record = itemobj.data('record');
        itemobj.remove();//删除拖拽过去的html
        var nodeobj = ld(evt.to);
        var nodeid = nodeobj.data('nodeid');
        var url = 'index.php?module='+that.frommodule+'&action='+that.frommodule+'Ajax&file=relationshipChart';
        url += '&frommodule='+that.frommodule+'&fromrecord='+record+'&chartmodule='+that.chartmodule;
        url += '&mode=getRelatedChart';
        ldAjax(url,{'maxnodeid':that.maxnodeid,'currentnodeid':nodeid,'relatedRecords':that.relatedRecordsArr.join(',')},function (data) {
            if (data.code == 1){//
                MessagePopup.TipTwo_warning(that.arrFixedLabelArr.takeChildrenNode);
                var messagepopupobj = CrmPopup.getPopupObj('last');
                ld('#'+messagepopupobj.divid).find('[tagclick=msgConfirm]').on('click',function () {
                    that.setParams(data.result);
                    var parentnodeid = that.relationshipChartDataArr[nodeid].parentnodeid;//原节点的父类id
                    var childrennodeid = that.relationshipChartDataArr[nodeid].childrennodeid;//原节点的子类id
                    delete that.relationshipChartDataArr[nodeid];//删除原节点数据
                    that.relationshipChartDataArr = ld.extend(that.relationshipChartDataArr,data.result.childRelationshipChartDataArr);//合并 原图谱+带出的图谱
                    that.haveRecordNodeArr = ld.extend(that.haveRecordNodeArr,data.result.child_haveRecordNodeArr);//合并 单据和节点的关系
                    //处理拖拽的目标节点的数据 parentnodeid,childrennodeid重新赋值
                    that.relationshipChartDataArr[nodeid].parentnodeid = parentnodeid;//父类
                    var new_childrennodeid = that.relationshipChartDataArr[nodeid].childrennodeid;//带出的子节点id
                    new_childrennodeid = ld.merge(childrennodeid.toString().split(','),new_childrennodeid.toString().split(','));//合并 原来的下级节点和新的下级节点
                    ld.each(new_childrennodeid,function (index,value) {
                        if (empty(value)){
                            new_childrennodeid.splice(index,1);
                        }
                    })
                    that.relationshipChartDataArr[nodeid].childrennodeid = new_childrennodeid.join(',');
                    that.showRelationshipChart();
                    that.getRepeatNode();
                    DelProgressObjs();
                });
                ld('#'+messagepopupobj.divid).find('[tagclick=msgConfirmCancel]').on('click',function () {
                    that.relationshipChartDataArr[nodeid].chartrecord = record;
                    that.haveRecordNodeArr[nodeid] = record;
                    that.showRelationshipChart();
                    DelProgressObjs();
                });
            }else if (data.code == 2){//没有下级节点
                that.relationshipChartDataArr[nodeid].chartrecord = record;
                that.haveRecordNodeArr[nodeid] = record;
                that.showRelationshipChart();
                DelProgressObjs();
            }

        });
    }


    //设置重复节点和事件
    this.getRepeatNode = function (){
        var haveRecordNodeArr = that.haveRecordNodeArr;
        that.repeatRecordArr = {};
        that.repeatNodeid = '';
        var tmp_arr = {};
        for (var nodeid in haveRecordNodeArr){//获取重复单据的节点并红框显示
            var record = haveRecordNodeArr[nodeid];
            if (!empty(tmp_arr[record])){
                that.divobj.find('#node_box_'+nodeid).addClass('repeat');
                if (tmp_arr[record].length == 1){
                    that.divobj.find('#node_box_'+tmp_arr[record][0]).addClass('repeat');
                }
                tmp_arr[record].push(nodeid);
                that.repeatRecordArr[record] = tmp_arr[record];
            }else {
                tmp_arr[record] = [nodeid];
            }
        }
        if (!empty(that.repeatRecordArr)){
            that.divobj.find('#repeatBtn').css('display','');
        }
    }

    //定位到重复节点
    this.setRepeatNodeEvent = function (){
        if (empty(that.repeatRecordArr)){
            that.divobj.find('#repeatBtn').css('display','none');
            return false;
        }
        //获取下一个节点
        if (empty(that.repeatNodeid)){
            var nodeid_arr = Object.values(that.repeatRecordArr);
            that.repeatNodeid =nodeid_arr[0][0];
        }else {
            var tmp_record = that.haveRecordNodeArr[that.repeatNodeid];//上一个记住的节点的单据
            var record_arr = Object.keys(that.repeatRecordArr);//重复数组的键
            var tmp_record_index =  record_arr.indexOf(tmp_record);//上一个节点的单据在record_arr的index
            var node_index = that.repeatRecordArr[tmp_record].indexOf(that.repeatNodeid);//节点在重复数组值中数组的index
            if (parseInt(node_index)+1 < that.repeatRecordArr[tmp_record].length){//该单据还有下一个节点
                that.repeatNodeid = that.repeatRecordArr[tmp_record][parseInt(node_index)+1];
            }else {//该单据无下一个节点
                if (parseInt(tmp_record_index)+1 < record_arr.length){//该单据后面还有单据的数据
                    tmp_record = record_arr[parseInt(tmp_record_index)+1]
                    that.repeatNodeid = that.repeatRecordArr[tmp_record][0];
                }else {
                    tmp_record = record_arr[0];
                    that.repeatNodeid = that.repeatRecordArr[tmp_record][0];
                }
            }
        }
        var viewobj = that.divobj.find('#relationshipChartView');
        //初始图谱
        viewobj.css('transform','translateX(0px) translateY(0px) scale('+that.scaleValue+')');
        var repeatnodeobj = that.divobj.find('#node_box_'+that.repeatNodeid);
        var screenWidth = window.innerWidth;
        var screenHeight = window.innerHeight;
        // 获取节点在图谱中的位置
        var innerRect = repeatnodeobj.get(0).getBoundingClientRect();
        // 计算节点的中心点偏移
        var innerCenterX = innerRect.left + innerRect.width / 2;
        var innerCenterY = innerRect.top + innerRect.height / 2;
        // 计算需要移动图谱的距离，使节点居中
        var translateX = (screenWidth / 2) - innerCenterX;
        var translateY = (screenHeight / 2) - innerCenterY;
        viewobj.css('transform','translateX('+translateX+'px) translateY('+translateY+'px) scale('+that.scaleValue+')');

    }



    //图谱节点右侧按钮事件
    this.setChartNodeEvent = function (){
        //节点显示右侧按钮事件
        var nodeboxobj = that.divobj.find("[tag=nodebox]");
        nodeboxobj.hover(function(){
            ld(this).find("[tag=nodeBtn]").css("display","none");
            var parentnodeid = ld(this).data('parentnodeid');
            var nodeid = ld(this).data('nodeid');
            var nodeinfo = that.relationshipChartDataArr[nodeid];
            if(parentnodeid == 0){//无上级 可添加上级
                ld(this).find("#addtop_"+nodeid).css("display","");
            }
            ld(this).find("#addbottom_"+nodeid).css("display","");//下级按钮
            if(nodeinfo.parentnodeid != 0){//有上级 可添加同级
                ld(this).find("#addright_"+nodeid).css("display","");
            }
            var tipobj = ld(this).find('[name=tip]');
            //没有下级节点 有上级节点 图谱节点数量>2 无"添加节点"提示
            if(empty(nodeinfo.childrennodeid) && nodeinfo.parentnodeid != 0 && Object.keys(that.relationshipChartDataArr).length > 2 && tipobj.length == 0){
                ld(this).find("#deletebox_"+nodeid).css("display","");
            }
            ld(this).find("#operation_"+nodeid).css("opacity","1");
            ld(this).find("#operation_"+nodeid).css("visibility","initial");
        },function(){
            var parentnodeid = ld(this).data('parentnodeid');
            var nodeid = ld(this).data('nodeid');
            ld(this).find("#operation_"+nodeid).css("opacity","0");
            ld(this).find("#operation_"+nodeid).css("visibility","hidden");
        });
        //节点右侧按钮事件绑定
        nodeboxobj.find('[tag=nodeBtn]').off('click').on('click',function () {
            that.changeChartNode(this);
        });
        //单据节点
        if (that.haveTagField == 'yes'){
            nodeboxobj.find('[tag=tagClick]').off('click').on('click',function () {
                that.showRecordTagSet(this);
            })
        }
        //单据节点
        nodeboxobj.find('[tag=deleteinfo]').off('click').on('click',function (event) {
            that.deleteNodeInfo(this);
            event.stopPropagation();
        })



    }

    //节点 新增删除
    this.changeChartNode = function (obj){
        var type = ld(obj).data('type');
        var current_nodeid = ld(obj).data('nodeid');
        var relationshipChartDataArr = that.relationshipChartDataArr;//图谱所有节点数据
        var current_nodeinfo = relationshipChartDataArr[current_nodeid];//该节点数据
        if (!empty(that.tagSetPopupobj)){//关闭标签弹窗
            ld('#'+that.tagSetPopupobj.divid+'_imgclose').click();
        }
        if (type == 'deletebox'){//删除节点
            var current_parentnodeid = current_nodeinfo.parentnodeid;
            var current_chartrecord = current_nodeinfo.chartrecord;
            var current_nodeid = current_nodeinfo.nodeid;
            if (!empty(current_chartrecord)){//带单据的节点删除时，需要删除单据节点关系的数据
                delete that.haveRecordNodeArr[current_nodeid];
            }
            var current_parentnode_childrennodeid = that.relationshipChartDataArr[current_parentnodeid].childrennodeid;
            var childrennodeid_arr = current_parentnode_childrennodeid.toString().split(',');
            var current_nodeid_index = childrennodeid_arr.indexOf(current_nodeid);
            childrennodeid_arr.splice(current_nodeid_index,1);
            that.relationshipChartDataArr[current_parentnodeid].childrennodeid = childrennodeid_arr.join(',');
            delete that.relationshipChartDataArr[current_nodeid];
            if (current_parentnodeid == that.maxnodeid){
                that.maxnodeid = 0;
                ld.each(that.relationshipChartDataArr,function (nodeid,info) {
                    that.maxnodeid = parseInt(nodeid) > parseInt(that.maxnodeid) ? parseInt(nodeid) : parseInt(that.maxnodeid);
                });
            }
        }else {//添加节点的事件
            var addnodeid = parseInt(that.maxnodeid) + 1;

            if (type == 'addtop'){//添加上级
                var addchildrennodeid = current_nodeid;
                var addparentnodeid = 0;
                //当前节点的上级
                that.relationshipChartDataArr[current_nodeid].parentnodeid = addnodeid;
            }else if (type == 'addright'){//向右添加同级节点
                var addchildrennodeid = '';
                var current_parentnodeid = current_nodeinfo.parentnodeid;
                var addparentnodeid = current_parentnodeid;
                //更新上级节点的下级节点数据
                var current_parentnode_childrennodeid = that.relationshipChartDataArr[current_parentnodeid].childrennodeid;
                var childrennodeid_arr = current_parentnode_childrennodeid.toString().split(',');
                var current_nodeid_index = childrennodeid_arr.indexOf(current_nodeid);
                childrennodeid_arr.splice(current_nodeid_index+1,0,addnodeid);
                that.relationshipChartDataArr[current_parentnodeid].childrennodeid = childrennodeid_arr.join(',');
            }else if (type == 'addleft'){//向左添加同级节点

                return '';
            }else if (type == 'addbottom'){//添加下级节点
                var addchildrennodeid = '';
                var addparentnodeid = current_nodeid;
                //更新当前节点数据
                var childrennodeid = current_nodeinfo.childrennodeid;
                if (empty(childrennodeid)){
                    that.relationshipChartDataArr[current_nodeid].childrennodeid = addnodeid;
                }else {
                    var childrennodeid_arr = current_nodeinfo.childrennodeid.toString().split(',');
                    childrennodeid_arr.push(addnodeid);
                    that.relationshipChartDataArr[current_nodeid].childrennodeid = childrennodeid_arr.join(',')
                }
            }

            that.maxnodeid = addnodeid;
            //新增数据
            that.relationshipChartDataArr[addnodeid] = {
                'chartrecord':'',
                'childrennodeid':addchildrennodeid,
                'nodeid':addnodeid,
                'parentnodeid':addparentnodeid
            };
        }
        //重新加载
        that.showRelationshipChart();
    }

    //显示单据标签设置界面
    this.showRecordTagSet = function (obj){
        var nodeid = ld(obj).data('nodeid');
        var chartrecord = that.relationshipChartDataArr[nodeid].chartrecord;
        if (chartrecord == '0' || empty(chartrecord) || that.leftListDataArr[chartrecord] == undefined || that.leftListDataArr[chartrecord].havepermittedtoview == 'no'){//没有数据或没有权限
            return false;
        }
        var surl = 'index.php?module='+that.chartmodule+'&action='+that.chartmodule+'Ajax&file=moduledata_tag&record='+chartrecord+'&ismodulemapedit=false';
        ldAjax(surl,'',function (data) {
            DelProgressObjs();
            if (data.code == 1){
                if (empty(that.tagSetPopupobj)){
                    var popupobj=CrmPopup.load(data.result.title,that.saveRecordTagSet,"",300,that.chartmodule,'',that.arrFixedLabelArr.saveTag,"",'');
                    popupobj.setPosition(CrmPopup.Positions.rightcenter);
                    that.tagSetPopupobj = popupobj;
                    popupobj.relationshipChartobj = that;
                    popupobj.popuptype = 'relationshipChartTag';
                    popupobj.show(data.result.content);
                    popupobj.crmpopuplayerobj.unblock();
                    popupobj.proportion = 1;
                }else {
                    var popupobj =that.tagSetPopupobj;
                    popupobj.show(data.result.content);
                }
                popupobj.chartrecord = chartrecord;
                moduledata_tag.allmodulelabel = data.result.allmodulelabel;
                that.divobj.find('#relationshipChartBtnRightDiv').animate({'padding-right':'300px'},200);
                // that.divobj.find('#relationshipChartBtnRightDiv').css('padding-right','320px');
                // that.divobj.find('#'+that.divid+'_imgclose').parent().css('padding-right',300+'px');
                ld('#'+popupobj.divid).css('top','0px');
                ld('#'+popupobj.divid).css('right','0px');
                var height = popupobj.getPopContentHeight();
                ld('#'+popupobj.divid).find('#setTagDiv').css('height',height+'px');
                ld('#'+popupobj.divid+'_imgclose').off('click').on('click',function () {
                    that.tagSetPopupobj = '';
                    that.divobj.find('#relationshipChartBtnRightDiv').animate({'padding-right':'20px'},200);
                })
                //去除上一次点击节点的选中效果
                if (!empty(that.lastClickNodeobj)){
                    that.lastClickNodeobj.removeClass('hovered')
                }
                //增加当前选中节点的效果
                ld(obj).addClass('hovered');
                that.lastClickNodeobj = ld(obj);
                //加载标签选中内容等
                tagger_class({el:'#input_tagger'});
            }
        })

    }

    //保存标签设置
    this.saveRecordTagSet = function (){
        var popupobj = that.tagSetPopupobj;
        var divobj = ld("#"+popupobj.divid);
        var record = popupobj.chartrecord;
        var new_moduledata_tag = divobj.find("[name=new_moduledata_tag]").val();
        var selected_moduledata_tag = divobj.find("[name=input_tagger]").attr('tag_id');
        var corp_tag = 'personal';
        //企业标签
        if(divobj.find("[name=corp_tag]") != undefined && divobj.find("[name=corp_tag]").is(':checked') == true){
            corp_tag = 'company';
        }
        var urlstring = 'index.php?module='+that.chartmodule+'&action='+that.chartmodule+'Ajax&ajax=true&file=moduledata_tag&save=true&record='+popupobj.chartrecord;
        var params = {'new_moduledata_tag':new_moduledata_tag,'selected_moduledata_tag':selected_moduledata_tag,'corp_tag':corp_tag};
        ldAjax(urlstring,params,function(data){
            if (data.code == 1){
                DelProgressObjs();
                var newTagDataObj = {};
                if (!empty(data.result.tag)){
                    var tag_arr = data.result.tag.toString().split(',');
                    var tag_type_arr = data.result.tag_type.toString().split(',');
                    var tag_id_arr=data.result.tag_id.toString().split(',');
                    ld.each(tag_id_arr,function (index,tag_id) {
                        newTagDataObj[tag_id] = {'tag':tag_arr[index],'tag_type':tag_type_arr[index]};
                    });
                }
                //更新数据
                that.tagDataByRecordArr[record] = newTagDataObj;
                //获取新的标签html
                var content = that.getTagContent(record);
                that.divobj.find('[tagrecord='+record+']').replaceWith(content);
                //刷新标签弹窗
                that.showRecordTagSet(that.lastClickNodeobj.get(0));

            }
        });
    }

    //删除节点内的单据
    this.deleteNodeInfo = function (obj){
        var nodeid = ld(obj).parent('[name=content]').data('nodeid');
        var chartrecord = that.relationshipChartDataArr[nodeid].chartrecord;
        //清除数据
        if (that.repeatRecordArr[chartrecord] != undefined){//清除重复
            var repeatnode_arr = that.repeatRecordArr[chartrecord];
            if (repeatnode_arr.length == 2){
                ld.each(repeatnode_arr,function (index,tmp_nodeid) {
                    that.divobj.find('#node_box_'+tmp_nodeid).removeClass('repeat');
                })
                delete that.repeatRecordArr[chartrecord];
            }else if (repeatnode_arr.length > 2){
                var tmpindex = repeatnode_arr.indexOf(nodeid);
                repeatnode_arr.splice(tmpindex,1);
                that.repeatRecordArr[chartrecord] = repeatnode_arr;
                that.divobj.find('#node_box_'+nodeid).removeClass('repeat');
            }
        }
        if (empty(that.repeatRecordArr)){
            that.divobj.find('#repeatBtn').css('display','none');
        }
        that.relationshipChartDataArr[nodeid].chartrecord = '';
        delete that.haveRecordNodeArr[nodeid];
        that.repeatNodeid = '';
        //获取节点显示内容
        var content = that.getShowContent('');
        that.divobj.find('#content_'+nodeid).html(content);
        that.divobj.find('#node_box_'+nodeid).attr('sortable','yes');
        that.divobj.find('#title_'+nodeid).html('');
        that.divobj.find('#deleteinfo_'+nodeid).css('display','none');
        that.divobj.find('#node_box_'+nodeid).removeClass('hovered');
        if (!empty(that.tagSetPopupobj)){//关闭标签弹窗
            ld('#'+that.tagSetPopupobj.divid+'_imgclose').click();

        }
        //刷新左侧部分
        that.showLeftListData();
    }

    //获取 按照"上级单位生成图谱"的数据
    this.getRelationshipChartByParentid = function (){
        var url = 'index.php?module='+that.frommodule+'&action='+that.frommodule+'Ajax&file=relationshipChart';
        url += '&frommodule='+that.frommodule+'&fromrecord='+that.fromrecord+'&chartmodule='+that.chartmodule;
        url += '&mode=getChartByParentid';
        var params = {'relatedRecords':that.relatedRecordsArr.join(',')};
        ldAjax(url,params,function (data) {
            DelProgressObjs();
            if (data.code == 1){
                MessagePopup.TipTwo_warning(that.arrFixedLabelArr.haveParenidDataMessageTip);
                var messagepopupobj = CrmPopup.getPopupObj('last');
                var confirm_button = ld('#'+messagepopupobj.divid).find('[tagclick=msgConfirm]');
                confirm_button.on('click',function () {
                    ld('#rptContentLoading').show();
                    that.setParams(data.result);
                    that.showRelationshipChart();
                    ld('#rptContentLoading').hide();
                });

            }else {
                MessagePopup.TipOne_warning(that.arrFixedLabelArr.haveNoParenidDataMessageTip);
            }
        })
    }

    //选择相关单据
    this.selectRelatedRecord = function (){
        var popuptype = 'AccountsChart';
        var selectRecords = that.relatedRecordsArr.join(',');
        var url = 'module='+that.chartmodule+'&action='+that.chartmodule+'Ajax&file=Popup&popuptype='+popuptype+'&selectListValue='+selectRecords;
        url += '&popup=yes&page_popup=yes&select=enable';
        url += '&frommodule='+that.frommodule+'&chartmodule='+that.chartmodule;
        that.AccountsChartUrl = '&selectListValue='+selectRecords+'&chartmodule='+that.chartmodule;
        CrmPopupWindow(that.frommodule, url, that.chartmodule);
        var popupobj = CrmPopup.getPopupObj('last');
        popupobj.relationshipChartobj = that;
    }

    //选择相关单据 客户图谱带出相关客户
    this.getRelatedRecord = function (){
        var popupobj = CrmPopup.getPopupObj('last');
        if (popupobj.chooseMainSourceInfo_arr.length == 0){
            MessagePopup.TipOne_warning(arrJsPopLabel['PLEASESELECTONEENTITY']);
            return false;
        }
        if (that.frommodule == 'Accounts' && that.chartmodule == 'Accounts'){
            var selectRelatedRecords = popupobj.chooseMainSourceInfo_arr.join(',');
            var relatedRecords = that.relatedRecordsArr.join(',');
            var url = 'index.php?module='+that.frommodule+'&action='+that.frommodule+'Ajax&file=relationshipChart';
            url += '&frommodule='+that.frommodule+'&fromrecord='+that.fromrecord+'&chartmodule='+that.chartmodule;
            url += '&mode=getRelatedRecords';
            var params = {'selectRelatedRecords':selectRelatedRecords,'oldRelatedRecords':relatedRecords};
            ldAjax(url,params,function (data) {
                if (data.code == 1){
                    DelProgressObjs();
                    popupobj.CancelEvent();
                    that.setParams(data.result);
                    that.showRelationshipChart();
                    if (data.result.haveMsgTip == 'yes'){
                        MessagePopup.TipZero_success(that.arrFixedLabelArr.BroughtOutRelatedRecords);//提示成功
                    }
                }
            })
        }

    }

    //图谱右上角放大缩小拖动图谱事件
    this.changeRelationshipChart = function (type){
        if (type == 'drag'){//拖动
            var dragBtnObj = that.divobj.find('#DragBtn');
            var nodewrapobj = that.divobj.find("#node_wrap_div");
            if(that.dragBtnStatus == 'no'){
                that.dragBtnStatus = 'yes';
                dragBtnObj.data('tip',arrJsPopLabel['LOCKMAP']);
                dragBtnObj.css('background-color','#3B7CFF');
                nodewrapobj.css('cursor','pointer');
            }
            else{
                that.dragBtnStatus = 'no';
                that.drag = false;
                dragBtnObj.data('tip',arrJsPopLabel['DRAGMAP']);
                dragBtnObj.css('background-color','');
                nodewrapobj.css('cursor','');
            }
            //图谱拖动
            that.setDragEvent();
        }else {
            //放大缩小，恢复
            var value=that.divobj.find('#ChangeValue').data('value');
            if(type=='restore') {
                value = 100;
                //恢复将图谱页恢复到正位,避免拖动直接不在屏幕范围呢后不能恢复
                that.divobj.find("#node_wrap_div").css('transform',"translate(0px,0px)");
            }
            else if(type=='out') {
                if(parseInt(value)<=50) {
                    return false;
                }
                value=parseInt(value)-10;
            }
            else{
                if(parseInt(value)>=300) {
                    return false;
                }
                value=parseInt(value)+10;
            }
            scale=parseFloat((value/100)).toFixed(1);
            that.scaleValue = scale;
            that.divobj.find('#ChangeValue').html(value+"%");
            that.divobj.find('#ChangeValue').data('value',value);
            that.divobj.find('#relationshipChartView').get(0).style.transform="scale("+scale+")";
        }
    }

    //拖动监听事件
    this.setDragEvent = function (){
        var nodewrapobj = that.divobj.find("#node_wrap_div");
        if (that.dragBtnStatus == 'yes'){
            nodewrapobj.addClass('forbidHightText');
            nodewrapobj.off('mousedown').on('mousedown',function(event){
                if(that.dragBtnStatus == 'no'){
                    return;
                }
                that.drag = true;
                if(ld(this).css('transform') == 'none'){
                    ld(this).css('transform',"translate(0px,0px)");
                }
                var translates = ld(this).css('transform');
                // 去除 matrix 前缀并将其分割成数组
                var matrixValues = translates.match(/matrix\((.+)\)/)[1].split(', ');
                // 获取 translateX 和 translateY
                var translateX = parseFloat(matrixValues[4]);
                var translateY = parseFloat(matrixValues[5]);
                that.translateX = event.clientX-translateX;
                that.translateY = event.clientY-translateY;

            })
            nodewrapobj.off('mousemove').on('mousemove',function(event){
                if(!that.drag){
                    return false;
                }
                var translateX = event.clientX-that.translateX;
                var translateY = event.clientY-that.translateY;
                ld(this).css('transform',"translate("+translateX+"px,"+translateY+"px)");

            })
            ld(nodewrapobj).off('mouseup').on('mouseup',function(event){
                that.drag = false;
            });
        }else {
            nodewrapobj.removeClass('forbidHightText');
            nodewrapobj.off('mousedown');
            nodewrapobj.off('mousemove');
            nodewrapobj.off('mouseup');
        }
    }

    //全屏
    this.fullScreen = function (){
        var url = 'index.php?module='+that.frommodule+'&action='+that.frommodule+'Ajax&file=relationshipChart';
        url += '&frommodule='+that.frommodule+'&fromrecord='+that.fromrecord+'&chartmodule='+that.chartmodule;
        url += '&mode=fullscreen';
        ldAjax(url,'',function (data) {
            if (data.code == 1){
                var popupobj = CrmPopup.load(data.result.title,'','',CrmPopup.getClientWidth(),data.result.frommodule,'','','','');
                popupobj.show(data.result.content);
                var cls_relationshipChartobj = new cls_relationshipChart(data.result.frommodule,data.result.fromrecord,data.result.chartmodule);
                cls_relationshipChartobj.setPopupObj(popupobj);
                cls_relationshipChartobj.setParams(data.result);
                cls_relationshipChartobj.showRelationshipChart();
                popupobj.relationshipChartobj = cls_relationshipChartobj;
                popupobj.center();
                DelProgressObjs();
            }
        });
    }

    //锁定状态改变
    this.changeLockStatus = function (){
        var lockstatus=that.lockstatus;
        var newlockstatus=(lockstatus == 'yes')?'no':'yes';
        var url = 'index.php?module='+that.frommodule+'&action='+that.frommodule+'Ajax&file=relationshipChart';
        url += '&frommodule='+that.frommodule+'&fromrecord='+that.fromrecord+'&chartmodule='+that.chartmodule;
        url += '&mode=changeLock';
        url += '&newlockstatus='+newlockstatus;
        ldAjax(url,'',function (data) {
            if (data.code == 1){
                that.lockstatus=data.result.lockstatus;
                var lockobj = that.divobj.find('#lockBtn');
                var editobj = that.divobj.find('#editBtn');
                if (that.lockstatus == 'yes'){
                    lockobj.css('display','block');
                    lockobj.addClass('chart-lock');
                    lockobj.removeClass('chart-unlock');
                    editobj.addClass('editBtnDisabled');
                    editobj.addClass('editBtnToolTip');
                    editobj.attr('disabled',true);
                    if (!that.editBtnToolTip){
                        that.editBtnToolTip = true;
                        tooltip('.editBtnToolTip',{transition: true, time: 200});
                    }
                }else if(that.lockstatus == 'no') {
                    lockobj.css('display','block');
                    lockobj.removeClass('chart-lock');
                    lockobj.addClass('chart-unlock');
                    editobj.removeClass('editBtnDisabled');
                    editobj.removeClass('editBtnToolTip');
                    editobj.attr('disabled',false);
                }else if (that.lockstatus == '-1') {
                    lockobj.css('display','none');
                }
                DelProgressObjs();
            }
        })
    }

    //显示字段设置 按钮显示弹窗
    this.showFieldSet = function (){
        var url = 'index.php?module='+that.frommodule+'&action='+that.frommodule+'Ajax&file=relationshipChart';
        url += '&frommodule='+that.frommodule+'&fromrecord='+that.fromrecord+'&chartmodule='+that.chartmodule;
        url += '&mode=showFieldSet';
        ldAjax(url,'',function (data) {
            if (data.code == 1){
                var popupobj = CrmPopup.load(data.result.title,that.saveShowFieldSet,'','LdPopWidth800px popMarginPadding',data.result.frommodule,'',data.result.oktext,'',data.result.canceltext);
                CrmPopup.setPopupobjHtmlContent_scroll(popupobj,data.result.content);
                standardFilterDisplay();
                popupobj.frommodule = data.result.frommodule;
                popupobj.relationshipChartobj = that;
                var tableobj = ld('#'+popupobj.divid).find("table#ModuleMapfieldTable");
                var LeftObj = tableobj.find("#AssmablyList");
                var RightObj = tableobj.find("#selectedAssmablyColumns");
                var Drag_Transfer = new DragTransfer();
                Drag_Transfer.SetDragTransfer(tableobj,LeftObj,RightObj,'reset','300');
                popupobj.center();
                DelProgressObjs();
            }
        });
    }

    //保存 显示字段设置
    this.saveShowFieldSet = function (){
        var popupobj = CrmPopup.getPopupObj('last');
        var rightTableobj = ld('#'+popupobj.divid).find('#selectedAssmablyColumns');
        var rightTableOptionobj = rightTableobj.find("option");
        if(rightTableOptionobj.length < 1) {
            MessagePopup.TipOne_warning(arrJsPopLabel['PLEASESELECTLEASTONEFIELD']);
            return false;
        };
        //设置图谱显示字段，最多设置10个字段
        if(rightTableOptionobj.length > 10) {
            MessagePopup.TipOne_warning(arrJsPopLabel['ONLY10FIELDALLOWED']);
            return false;
        };
        var showFields= [];
        rightTableOptionobj.each(function(){
            showFields.push(ld(this).val());
        });
        showFields = showFields.join(',');

        var url = 'index.php?module='+that.frommodule+'&action='+that.frommodule+'Ajax&file=relationshipChart';
        url += '&frommodule='+that.frommodule+'&fromrecord='+that.fromrecord+'&chartmodule='+that.chartmodule;
        url += '&mode=saveShowFieldSet';
        var paramobj = {'relatedRecords':that.relatedRecordsArr.join(','),'showFields':showFields}
        ldAjax(url,paramobj,function (data) {
            if (data.code == 1){
                popupobj.CancelEvent();
                that.setParams(data.result);
                that.showRelationshipChart()
                DelProgressObjs();
            }
        })

    }






}