function DragTransfer(){
    var that = this;
    var cls_this = this;
    this.tableObj = ''; //新table对象
    this.original_tableObj = '';//原table对象
    this.setType = '';  //重建样式：reset，新建：set
    this.ori_LeftObj = '';  //原左侧对象
    this.ori_RightObj = ''; //原右侧对象
    this.ori_LeftObjID = '';
    this.ori_RightObjID = '';
    this.right_Sortable = true;//控制右侧是否允许上下排序
    this.need_resetLabelClick = true;//是否需要重新赋予label中for和对应input的id的对应点击事件
    //字符初始化
    this.translabel = {
        available: arrJsPopLabel['Available_fields'],
        selected: arrJsPopLabel['Selected_Fields'],
        placeholder: arrJsPopLabel['PleaseEnterFieldSearchFor'],
    };
    this.Poptype = '';//弹窗作用类型，穿梭框，排序，显示隐藏字段

    //左移右移
    this.moveSelected = function (moveaction) {
        var srcObj = '';
        var destObj = '';
        var ori_srcObj = '';
        var ori_destObj = '';
        if(moveaction == 'moveright'){
            srcObj = cls_this.tableObj.find(" #AssmablyList_Left");
            destObj = cls_this.tableObj.find(" #selectedAssmablyColumns_Right");
            ori_srcObj = cls_this.ori_LeftObj;
            ori_destObj = cls_this.ori_RightObj;
        }else{
            srcObj = cls_this.tableObj.find(" #selectedAssmablyColumns_Right");
            destObj = cls_this.tableObj.find(" #AssmablyList_Left");
            ori_srcObj = cls_this.ori_RightObj;
            ori_destObj = cls_this.ori_LeftObj;
        }
        srcObj_len = srcObj.children().length;
        destObj_len = destObj.children().length;
        if (typeof (srcObj) == 'undefined' || typeof (destObj) == 'undefined') return;
        for (i = 0; i < destObj_len; i++) {
            destObj.find("input").prop("checked", false);
            destObj.prev().find("input").prop("checked", false);
        }
        ld.each(srcObj.children(), function () {
            if (ld(this).find("input").is(":checked") == true) {
                var rowFound = false;
                var existingObj = null;
                var that = this;
                ld.each(destObj.children(), function () {
                    if (ld(this).find("label").attr('value') == ld(that).find("label").attr('value')) {
                        ld(that).children().remove();//无论默认有无，都去掉该备选项 ,               
                        rowFound = true;
                        existingObj = ld(this).find("input");
                        return false;
                    }
                })
                if (rowFound != true) {
                    newColObj_value = ld(this).find("label").attr('value');
                    if (browser_ie) {
                        newColObj_text = ld(this).find("label").text();
                    }
                    else if (browser_nn4 || browser_nn6) {
                        newColObj_text = ld(this).find("label").text();
                    }
                    if (moveaction == 'moveright') { //右移
                        newColObj_html = '<div class="ld-category-draggable ld-TransferSelect">'
                            + '<input id="' + newColObj_text + '" type="checkbox">'
                            + '<label value="' + newColObj_value + '" for="' + newColObj_text + '">' + newColObj_text + '</label>'
                            + '<div><a align="right" class="ld-dragicon drag-handle sort-tip-items" data-tip="' + arrJsPopLabel["DRAGTOSORT"] + '"  data-direction="right" data-type="position" style="float: right;margin-top: -5px;cursor: move;display:none;"></a></div>'
                            + '</div>';
                    } else if (moveaction == 'moveleft') { //左移
                        newColObj_html = '<div class="ld-category-draggable ld-TransferSelect">'
                            + '<input id="' + newColObj_text + '" type="checkbox">'
                            + '<label value="' + newColObj_value + '" for="' + newColObj_text + '">' + newColObj_text + '</label>'
                            + '<div><a align="right" class="ld-dragicon drag-handle sort-tip-items" data-tip="' + arrJsPopLabel["MoveRightToDisplay"] + '"  data-direction="right" data-type="position" style="float: right;margin-top: -5px;cursor: move;display:none;"></a></div>'
                            + '</div>';
                    }
                    ld(destObj).append(newColObj_html)//右键
                    if(ori_srcObj.length>0 && ori_destObj.length>0){
                        cls_this.moveOption(ori_srcObj,ori_destObj);
                    }
                    cls_this.tableObj.find("div[name='selectedAssmablyColumns_Right']").children().off('hover').hover(function() {//重新绑定拖动图标的hover
                        cls_this.tableObj.find('.ld-dragicon').hide();
                        ld(this).find('.ld-dragicon').show();
                    });
                    cls_this.tableObj.find("div[name='AssmablyList_Left']").children().off('hover').hover(function() {//重新绑定拖动图标的hover
                        cls_this.tableObj.find('.ld-dragicon').hide();
                        ld(this).find('.ld-dragicon').show();
                    });
                    cls_this.tableObj.find(" div[name='selectedAssmablyColumns_Right'],div[name='AssmablyList_Left']").children().unbind('mouseleave').mouseleave(function(){
                        ld(this).find('.ld-dragicon').hide();
                    });
                    ld(this).find("input").prop("checked", false);
                    ld(this).remove();
                    i=-1;
                    ld(destObj).find('label:last').focus();
                    ld(destObj).find('input:last').prop("checked",true);
                
                    rowFound=false;

                } else {
                    if (existingObj != null)
                        existingObj.prop("checked", true);
                }
            }
        })
        // 清空全选按钮选中的状态
        cls_this.tableObj.find("#selectAll_left").prop('checked',false);
        cls_this.tableObj.find("#selectAll_right").prop('checked',false);
        tooltip('.sort-tip-items', {transition: true, time: 200});
        cls_this.MultipleSelected();
    }
    //字符翻译
    this.SetTranslabel = function(translabel){
        this.translabel = translabel;
    }
    //重写html                                 
    this.SetDragTransfer = function(parentObj,LeftObj,RightObj,setType='reset',width='300'){
        if(setType == 'reset'){
            parentObj.find('tr').each(function() {
                if (ld(this).find('th').length === 0) {
                    ld(this).css('display','none');
                }
            });
            cls_this.ori_LeftObj = LeftObj;
            cls_this.ori_RightObj = RightObj;
            if(LeftObj != ''){
                cls_this.ori_LeftObjID = LeftObj.attr('id');
            }
            cls_this.ori_RightObjID = RightObj.attr('id');
        }
        cls_this.setType = setType;
        //判断用途
        if(LeftObj == '' && this.right_Sortable == false){
            this.Poptype = 'showhidden';//显示隐藏
        }else if(typeof LeftObj == 'string' && LeftObj == '' && this.right_Sortable == true){
            this.Poptype = 'sort';//排序
        }else{
            this.Poptype = 'transfer';//穿梭框
        }
        //parentObj.siblings("table").find('tr').css('display','none');
        var tablehtml = '';
        if(!parentObj.is('table')){//判断传进来的父级对象是否为table
            var tmp_parentObj = parentObj;
            if(parentObj.find('table.DragTransferTable').length < 1){
                var tmp_tablehtml = '<table class="DragTransferTable" border="0" cellpadding="0" cellspacing="0"></table>';
                parentObj.append(tmp_tablehtml);
            }
            parentObj = parentObj.find('table.DragTransferTable');
            cls_this.tableObj = parentObj;
            if(parentObj.find('table').length < 2){//判断父级对象内部是否本来就有table

            }else if(parentObj.find('table').length > 1){
                cls_this.original_tableObj = tmp_parentObj.find('table');
            }
        }else if(parentObj.is('table')){
            cls_this.tableObj = parentObj;
            cls_this.original_tableObj = parentObj;
        }
        if(LeftObj.length>0 && LeftObj.jquery){
            var LeftOptions = LeftObj.find("option");
            var LeftContent_arr = [];
            LeftOptions.each(function() {
                var option = $(this);
                var value = option.value;
                var text = option.innerText
                //wym 240131 BUG20240126-22 移动端工作台定制，“自定义报表”编辑界面，已选模块中显示异常(text为空时不要显示出来)
                if(!empty(text)){
                    LeftContent_arr.push({ value: value, text: text });
                }
            });
        }else{
            LeftContent_arr = LeftObj;
        }
        if(RightObj.length>0 && RightObj.jquery){
            var RightOptions = RightObj.find("option");
            var RightContent_arr = [];
            RightOptions.each(function() {
                var option = $(this);
                var value = option.value;
                var text = option.innerText
                //wym 240131 BUG20240126-22 移动端工作台定制，“自定义报表”编辑界面，已选模块中显示异常(text为空时不要显示出来)
                if(!empty(text)){
                    RightContent_arr.push({ value: value, text: text });
                }
            });
        }else{
            RightContent_arr = RightObj;
        }

        if(cls_this.right_Sortable == true){
            var leftlist_width = '42%';
            var rightlist_width = '42%';
            var transferbtn_width = '8%';
        }else{
            var leftlist_width = '47%';
            var rightlist_width = '46%';
            var transferbtn_width = '8%';
        }

        tablehtml += '<tr name="DragTransfer_tr">'
        if(this.Poptype != 'showhidden' && this.Poptype != 'sort'){
            tablehtml += '<td width="'+leftlist_width+'" class="pad10">'
                        +'<b>'+cls_this.translabel.available+'</b><br>'
                        +'<input class="ld-input-inner" id="keywordsearch_Left" style="width:'+width+'px;margin-top: 8px;" type="text"'
                        +'tag="'+cls_this.translabel.placeholder+'" placeholder="'+cls_this.translabel.placeholder+'" name="allmember" /><br>'
                        
                        +'<div class="ld-selectAll" align="left" style="width: '+width+'px;">'
                        +'<input type="checkbox" id="selectAll_left"/>'
                        +'<label value="" for="selectAll_left">' + arrJsPopLabel["ALLSELECT"] + '</label></div>'
                        +'<div style="height: 270px;width: '+width+'px;margin-top: 0px;border: 1px solid #f0f3f7;background-color: #F9FAFC;overflow: hidden auto;" class="commonMultipleSelect" name="AssmablyList_Left" id="AssmablyList_Left" multiple="">'
                        
            for (var i = 0; i < LeftContent_arr.length; i++) {
                tablehtml += '<div class="ld-category-draggable ld-TransferSelect">'
                +'<input id="'+LeftContent_arr[i].value+'" type="checkbox">'
                +'<label value="'+LeftContent_arr[i].value+'" for="'+LeftContent_arr[i].value+'">'+LeftContent_arr[i].text+'</label>'
                +'<div><a align="right" class="ld-dragicon drag-handle sort-tip-items" data-tip="' + arrJsPopLabel["MoveRightToDisplay"] + '"  data-direction="right" data-type="position" style="float: right;margin-top: -5px;cursor: move;display:none;"></a></div></div>';
            }
            tablehtml += '</div></td>';
        
            tablehtml += '<td width="'+transferbtn_width+'" class="pad10" style="text-align: center;">'
                        +'<a class="ld-icon-newhomearr-mright ld-icon-movetoright sort-tip-btn" href="javascript:;" data-tip="' + arrJsPopLabel["MOVERIGHT"] + '" data-direction="top" data-type="position"></a><br>'
                        +'<a class="ld-icon-newhomearr-mleft ld-icon-movetoleft sort-tip-btn" style="margin-top:15px;" href="javascript:;" data-tip="' + arrJsPopLabel["MOVELEFT"] + '" data-direction="bottom" data-type="position"></a></td>';
        }
        tablehtml += '<td width="'+rightlist_width+'" class="pad10">'
                    +'<b>'+cls_this.translabel.selected+'</b>'
                    if(cls_this.translabel.selected != '') tablehtml += '<br>';
        tablehtml += '<input class="ld-input-inner" id="keywordsearch_Right" style="width:'+width+'px;margin-top: 8px;" type="text"'
                    +'tag="'+cls_this.translabel.placeholder+'" placeholder="'+cls_this.translabel.placeholder+'" name="allmember" /><br>'

                    +'<div class="ld-selectAll" align="left" style="width: '+width+'px;">'
                    +'<input type="checkbox" id="selectAll_right"/>'
                    +'<label value="" for="selectAll_right">' + arrJsPopLabel["ALLSELECT"] + '</label></div>'
                    +'<div size="11" style="height: 270px;width: '+width+'px;margin-top: 0px;border: 1px solid #f0f3f7;background-color: #F9FAFC;" class="commonMultipleSelect" name="selectedAssmablyColumns_Right" id="selectedAssmablyColumns_Right" multiple="">'
        for (var i = 0; i < RightContent_arr.length; i++) {
            tablehtml += '<div class="ld-category-draggable ld-TransferSelect">'
                    +'<input id="'+RightContent_arr[i].value+'" type="checkbox">'
                    +'<label value="'+RightContent_arr[i].value+'" for="'+RightContent_arr[i].value+'">'+RightContent_arr[i].text+'</label>'
                    
            if(cls_this.right_Sortable == true){
                tablehtml += '<div><a align="right" class="ld-dragicon drag-handle sort-tip-items" data-tip="' + arrJsPopLabel["DRAGTOSORT"] + '" data-direction="right" data-type="position" style="float: right;margin-top: -5px;cursor: move;display:none;"></a></div>';
            }
            tablehtml += '</div>';
        }
        tablehtml += '</div></td>'
        if(cls_this.right_Sortable == true){
            tablehtml += '<td class="pad10" width="'+transferbtn_width+'" style="text-align: center;">'
                    +'<a class="ld-icon-newhomearr-mup ld-icon-moveup sort-tip-btn" href="javascript:;" data-tip="' + arrJsPopLabel["MOVEUP"] + '" data-direction="top" data-type="position"></a><br>'
                    +'<a class="ld-icon-newhomearr-mdown ld-icon-movedown sort-tip-btn" style="margin-top:15px;" href="javascript:;" data-tip="' + arrJsPopLabel["MOVEDOWN"] + '" data-direction="bottom" data-type="position"></a>'
                    +'</td>'
        }
        tablehtml += '</tr>';
        parentObj.append(tablehtml);
        // parentObj.html(tablehtml);
        parentObj.addClass('DragTransferTable');
        this.setdraggable();
        this.MultipleSelected();
        this.BindOnclickEvent();
        if(setType == 'reset'){
            this.changeOption();
        }
        var popupobj = CrmPopup.getPopupObj('last');
        if (popupobj != undefined && popupobj.hasOwnProperty('center')){
            popupobj.center();
        }
        
        tooltip('.sort-tip-btn', {transition: true, time: 200});
        tooltip('.sort-tip-items', {transition: true, time: 200});
    }
    //动态绑定点击事件
    this.BindOnclickEvent = function () {
        // var popupobj=CrmPopup.getPopupObj("last");
        // console.log(popupobj)
        this.tableObj.find(" .ld-icon-movetoright").unbind('click').on('click', function (event) {
            that.moveSelected('moveright');
        })
        this.tableObj.find(" .ld-icon-movetoleft").unbind('click').on('click', function (event) {
            that.moveSelected('moveleft');
        })
        this.tableObj.find(" .ld-icon-moveup").unbind('click').on('click', function (event) {
            that.MoveUp();
        })
        this.tableObj.find(" .ld-icon-movedown").unbind('click').on('click', function (event) {
            that.MoveDown();
        })
        if(this.Poptype == 'transfer'){
            this.tableObj.find(" #AssmablyList_Left").unbind('click').on('dblclick', function (event) {
                that.dbclickMove('AssmablyList_Left','selectedAssmablyColumns_Right',event);
            })
            this.tableObj.find(" #selectedAssmablyColumns_Right").unbind('click').on('dblclick', function (event) {
                that.dbclickMove('selectedAssmablyColumns_Right','AssmablyList_Left',event);
            })
        }
        this.tableObj.find("input#keywordsearch_Left").unbind('keyup').on('keyup', function (event) {
            that.KeyWordsSearch(this,'AssmablyList_Left');
        })
        this.tableObj.find("input#keywordsearch_Right").unbind('keyup').on('keyup', function (event) {
            that.KeyWordsSearch(this,'selectedAssmablyColumns_Right');
        })
        this.tableObj.find(" #selectAll_left").unbind('click').on('click', function (event) {
            that.SelectAll(this);
        })
        this.tableObj.find(" #selectAll_right").unbind('click').on('click', function (event) {
            that.SelectAll(this);
        })
        if(this.Poptype == 'showhidden'){
            this.tableObj.find(" #selectedAssmablyColumns_Right").find('input').unbind('click').on('click', function (event) {
                that.changeSingleOption(this);
            })
        }
    };
    //全选
    this.SelectAll = function (obj){
        if(ld(obj).is(":checked")==true){
            ld.each(ld(obj).parent().next(),function(index,allobj){
                ld(allobj).find("input").prop("checked",true);
            })
        }else{
            ld(obj).parent().next().find("input").prop("checked",false);
        }
        if(that.Poptype == 'showhidden'){
            that.changeOption();
        }
    }
    //双击移动点击事件
    this.dbclickMove = function(source,destination,event) 
    {
        var tmp_source = source;
        var source = cls_this.tableObj.find("#"+source).get(0);// var source = document.getElementById(source);
        var destination = cls_this.tableObj.find("#"+destination).get(0);// var destination = document.getElementById(destination);
        // 获取source div
        var availListObj = source.getElementsByClassName("ld-TransferSelect");
        for (var i = 0; i < availListObj.length; i++) {
            // 被选中元素的父级div
            if (event.target.parentNode == availListObj[i]) {
                targetObj = availListObj[i];
                source.removeChild(targetObj);
                destination.appendChild(targetObj);
                break;
            }
        }
        ld(destination).find('label:last').focus();
        ld(destination).find('input:last').prop("checked",true);
        if(tmp_source == 'AssmablyList_Left'){
            ld(targetObj).find('a.ld-dragicon').attr('data-tip',arrJsPopLabel['DRAGTOSORT']);
        }else{
            ld(targetObj).find('a.ld-dragicon').attr('data-tip',arrJsPopLabel['MoveRightToDisplay']);
        }
        if(cls_this.setType == 'reset'){
            var labelValue = ld(event.target).attr('value');
            if(tmp_source == 'AssmablyList_Left'){
                var target_option = cls_this.original_tableObj.find('#'+ cls_this.ori_LeftObjID +' option[value="' + labelValue + '"]');
                target_option.remove();
                cls_this.ori_RightObj.append(target_option);
            }else{
                target_option = cls_this.original_tableObj.find('#'+ cls_this.ori_RightObjID +' option[value="' + labelValue + '"]');
                target_option.remove();
                cls_this.ori_LeftObj.append(target_option);
            }
        }
    }
    //上移 XUQIU1001802 xxy 2023-8-17 序时簿列表--查询分类--增加多选、多选上下移动
    this.MoveUp = function(){
        var elem = cls_this.tableObj.find("#selectedAssmablyColumns_Right").get(0);// document.getElementById('selectedAssmablyColumns_Right');
        var options = elem.getElementsByClassName('ld-TransferSelect');
        var selectedOptions = [];// 存储所有选中的元素
        for (var i = 0; i < options.length; i++) {
            var inputElem = options[i].getElementsByTagName('input')[0];
            if (inputElem.checked == true) {
                selectedOptions.push(options[i]);
            }
        }
        //检查是否选中的元素中首个已经是第一个，如果是则不进行上移操作
        if (selectedOptions.length == 0 || selectedOptions[0] == options[0]) {
            return;
        }
        for (var i = 0; i < selectedOptions.length; i++) {
            var current = selectedOptions[i];
            var previous = current.previousElementSibling;
    
            if (previous) {
                elem.insertBefore(current, previous);
                current.getElementsByTagName("input")[0].checked = true;
                previous.getElementsByTagName("input")[0].checked = false;
            }
        }
        if(cls_this.setType == 'reset'){
            cls_this.changeOption();
            var elem = cls_this.ori_RightObj.get(0);
            if(elem.options.selectedIndex>=0){
                for (var i=1;i<elem.options.length;i++){
                    if(elem.options[i].selected == true){

                        var first = elem.options[i-1];
                        var second = elem.options[i];
                        var temp = new Array();
            
                        temp.value = first.value;
                        temp.innerHTML = first.innerHTML;
            
                        first.value = second.value;
                        first.innerHTML = second.innerHTML;
            
                        second.value = temp.value;
                        second.innerHTML = temp.innerHTML;
            
                        first.selected = true;
                        second.selected = false;
                    }
                }
            }
        }
    }
    //下移
    this.MoveDown = function(){
        var elem = cls_this.tableObj.find("#selectedAssmablyColumns_Right").get(0);// document.getElementById('selectedAssmablyColumns_Right');
        var options = elem.getElementsByClassName('ld-TransferSelect');

        // 用一个数组来存储所有选中的元素
        var selectedOptions = [];
        for (var i = 0; i < options.length; i++) {
            var inputElem = options[i].getElementsByTagName('input')[0];
            if (inputElem.checked == true) {
                selectedOptions.push(options[i]);
            }
        }
        
        // 检查是否选中的元素已经是最后一个，如果是则不进行下移操作
        if (selectedOptions.length === 0 || selectedOptions[selectedOptions.length - 1] === options[options.length - 1]) {
            return;
        }

        // 从底部开始遍历选中的元素，并一一下移
        for (var i = selectedOptions.length - 1; i >= 0; i--) {
            var current = selectedOptions[i];
            var next = current.nextElementSibling;
            elem.insertBefore(next, current);
            current.getElementsByTagName('input')[0].checked = true;
            next.getElementsByTagName('input')[0].checked = false;
        }
        if(cls_this.setType == 'reset'){
            cls_this.changeOption();
            var elem = cls_this.ori_RightObj.get(0);
            if(elem.options.selectedIndex>=0){
                for (var i=elem.options.length-2;i>=0;i--){
                    if(elem.options[i].selected == true){
                        //swap with one down
                        var first = elem.options[i+1];
                        var second = elem.options[i];
                        var temp = new Array();

                        temp.value = first.value;
                        temp.innerHTML = first.innerHTML;

                        first.value = second.value;
                        first.innerHTML = second.innerHTML;

                        second.value = temp.value;
                        second.innerHTML = temp.innerHTML;

                        first.selected = true;
                        second.selected = false;
                    }
                }
            }
        }
    }
    //拖拽
    this.setdraggable = function (){
        cls_this.tableObj.find(" div[name='selectedAssmablyColumns_Right'],div[name='AssmablyList_Left']").children().hover(function() {
            cls_this.tableObj.find('.ld-dragicon').hide();
            ld(this).find('.ld-dragicon').show();
        });
        cls_this.tableObj.find(" div[name='selectedAssmablyColumns_Right'],div[name='AssmablyList_Left']").children().mouseleave(function(){
            ld(this).find('.ld-dragicon').hide();
        });

        if(cls_this.tableObj.find(" div[name='selectedAssmablyColumns_Right']").children().length >= 0) {
            var oldIndex = 0;
            Sortable.create(cls_this.tableObj.find(" div[name='selectedAssmablyColumns_Right']").get(0), {
                group: 'fieldlayout',
                draggable: ".ld-category-draggable",
                handle: ".drag-handle",
                animation: 150,
                sort: cls_this.right_Sortable,
                onStart: function(evt) {
                    oldIndex = evt.oldIndex; // 存储开始时的位置
                },
                onEnd: function (evt) {
                    if (evt.from != evt.to) { //移动至另一个容器时才改变data-tip
                        ld(evt.item).find('a.ld-dragicon').attr('data-tip',arrJsPopLabel['MoveRightToDisplay']);
                    }
                    var newIndex = evt.newIndex; // 获取新的位置
                    if(cls_this.setType == 'reset'){
                        if (evt.from === evt.to) { //判断是否在同一容器中移动
                            cls_this.dragUpDownOption(oldIndex, newIndex);//上下移
                        }else{
                            var itemValue = ld(evt.item).find('label').attr('value');
                            cls_this.dragMoveOption(cls_this.ori_RightObjID, cls_this.ori_LeftObjID, itemValue, newIndex);//左右移
                        }
                    }
                }
            });
        }
        if(cls_this.ori_LeftObj != '' || cls_this.tableObj.find(" div[name='AssmablyList_Left']").length > 0){
            Sortable.create(cls_this.tableObj.find(" div[name='AssmablyList_Left']").get(0), {
                group: 'fieldlayout',
                draggable: ".ld-category-draggable",
                handle: ".drag-handle",
                animation: 150,
                sort: false,
                onEnd: function (evt) {
                    if (evt.from != evt.to) { ///移动至另一个容器时才改变data-tip
                        ld(evt.item).find('a.ld-dragicon').attr('data-tip',arrJsPopLabel['DRAGTOSORT']);
                    }
                    if(cls_this.setType == 'reset'){
                        var newIndex = evt.newIndex;
                        var itemValue = ld(evt.item).find('label').attr('value');
                        cls_this.dragMoveOption(cls_this.ori_LeftObjID, cls_this.ori_RightObjID, itemValue, newIndex);
                    }
                }
            });
        }
    }
    //拖拽左右移动option
    this.dragMoveOption = function(fromSelectId, toSelectId, optionValue, index) {
        var fromSelect = cls_this.original_tableObj.find('#' + fromSelectId);
        var toSelect = cls_this.original_tableObj.find('#' + toSelectId);
        var option = fromSelect.find('option[value="' + optionValue + '"]');//找到移动前option
        var referenceOption = toSelect.children('option').eq(index);//根据传来的位置，找到目标位置

        if (referenceOption.length) {
            option.insertBefore(referenceOption);//插入到目标位置option前
        } else {
            toSelect.append(option);
        }
    }
    //拖拽上下移动option
    this.dragUpDownOption = function(from, to) {
        var options = cls_this.ori_RightObj.children('option');
        if (from < to) {//移动前位置小于目标位置，就插入在目标位置option后
            options.eq(from).insertAfter(options.eq(to));
        } else {
            options.eq(from).insertBefore(options.eq(to));
        }
    }
    //鼠标多选
    this.MultipleSelected = function () {
        cls_this.tableObj.find('.ld-TransferSelect').off('mousedown mouseover mouseup click');//先去除绑定事件

        cls_this.tableObj.ready(function () {
            var isMouseDown = false;
            var isSelecting = false;
            
            cls_this.tableObj.find('.ld-TransferSelect').mousedown(function (event) {
                // console.log(event.target);
                if(ld(event.target).hasClass('drag-handle')){
                    return;
                }else if(ld(event.target).is('input')){
                    return;
                }
                isMouseDown = true;
                
                // 获取当前行关联的input元素
                const ldinput = ld(this).find('input:first');
                
                // 切换当前行的选中状态
                isSelecting = !ldinput.prop('checked');
                ldinput.prop('checked', isSelecting);
                ld(this).children().trigger('change');//手动触发change事件，changeOption函数需要用到change事件
                // 阻止默认行为但允许事件继续传播
                event.preventDefault();
        
            }).mouseover(function () {
                if (isMouseDown) {
                    // 获取当前行关联的input元素
                    const ldinput = ld(this).find('input:first');
                    
                    // 设置当前行的选中状态
                    ldinput.prop('checked', isSelecting);
                    ld(this).children().trigger('change');
                }
            }).bind("selectstart", function () {
                return false;
            });
        
            cls_this.tableObj.mouseup(function () {
                isMouseDown = false;
                if(that.Poptype == 'showhidden'){
                    that.changeOption();
                }
            });

            if(cls_this.need_resetLabelClick == true){
                // 独立处理label的点击事件
                cls_this.tableObj.find('.ld-TransferSelect label').unbind('click').click(function (event) {
                    const ldassociatedInput = ld(this).siblings('input:first');
                    ldassociatedInput.prop('checked', !ldassociatedInput.prop('checked'));
                    ld(this).children().trigger('change');
                });
            }
        });
    };
    //关键字搜索
    this.KeyWordsSearch = function(obj,inputname){
        var input_obj = '';
        var popupobj=CrmPopup.getPopupObj("last");
        if(popupobj == undefined || popupobj.divid == undefined){
            input_obj= ld(obj).siblings(" div[name="+inputname+"]");
        }else{
            if(ld("#"+popupobj.divid+" [name="+inputname+"]") != undefined){
                input_obj = ld("#"+popupobj.divid).find(this.tableObj).find(" [name="+inputname+"]");
            }
        }
        
        if(input_obj != ''){
            var selectlength = input_obj.find('div').length/input_obj.length;
            var isSel=0;
            var isSelectOpteion =0;
            var objlength = obj.value.length;

            if(obj.value != '')
            {
                getScriptBack('include/js/multipingyin.js',null);//加载拼音代码  BUG0066311 ls 20230515 cdn慢,导致pakePy方法报错,改为加载本地js
                var selectHeight = input_obj[0].scrollHeight;//下拉框的高度
                var optionHeight = selectHeight/selectlength;
                ld.each(input_obj.find('div'), function (keys, selobj) {
                    var selectValue =ld(selobj).find("label").text();
                    var selT = selectValue.indexOf(trim(obj.value));
                    var pinyin = makePy(selectValue);//17222: (71mis.com/crm)控制面板>部门设置/权限管理,关于设置成员模糊搜索的问题
                    pinyin=pinyin.join("").toLowerCase();

                    //pinyinArray[i]=pinyin;
                    var selP = pinyin.indexOf(trim(obj.value));
                    if(selT >=0 || selP >=0)
                    {
                        if(isSel == 0)
                        {
                            if(selP > 0){
                                if(pinyin.indexOf(trim(obj.value))>0){
                                    ld(selobj).find("input").prop("checked", true);
                                    isSel = 1
                            }
                                //if(pinyin.substring(0, objlength) == obj.value){
                                    //objMember.options[i].selected = true;
                                    //isSel = 1;
                                //}
                            }
                            else{
                                ld(selobj).find("input").prop("checked", true);
                                isSel = 1;
                            }
                            
                            isSelectOpteion = keys;
                        }
                        else{
                            ld(selobj).find("input").prop("checked", false);
                        }
                    }
                    else{
                        if(ld(selobj).find("input").is(":checked") == true)
                        {
                            ld(selobj).parent().prev().find("input").prop("checked", false);
                            ld(selobj).find("input").prop("checked", false);
                        }
                    }
                    if(that.Poptype == "showhidden"){
                        that.changeSingleOption(ld(selobj).find("input")[0]);
                    }
                });
                if(isSelectOpteion >=10){
                    input_obj.animate({ scrollTop: optionHeight*isSelectOpteion-50});
                }else{
                    input_obj.animate({ scrollTop: 0});
                }
                
            }else{
                ld.each(ld("#"+popupobj.divid+" [name="+inputname+"] option "), function (keys, selobj) {
                    if(ld(selobj).find("input").is(":checked") == true)
                    {
                        ld(selobj).find("input").prop("checked", false);
                    }
                });
                isSel = 0;
                input_obj.scrollTop(0);
            }
        }

    }
    //根据datatype获取左或右侧数据
    this.getData = function (type,datatype='') {
        var selObjinfo = [];
        if(type == 'right'){
            var selObj = cls_this.tableObj.find('#selectedAssmablyColumns_Right');

            // if (selObj.length == 0) {
            //     var confirm_str = arrJsPopLabel['CATEGORYNAMECANOTEMPTY'];
            //     MessagePopup.TipOne_warning(confirm_str);
            //     return false;
            // }
            // //判断显示列大于三列
            // else if (selObj.length < 3) {
            //     var confirm_str = arrJsPopLabel['COLUMNSELECTLEASTTHREE'];
            //     MessagePopup.TipOne_warning(confirm_str);
            //     return false;
            // };
        }else{
            var selObj = cls_this.tableObj.find('#AssmablyList_Left');
            
        }
        selObj = selObj.children();
        if(datatype == 'array'){
            var tmp_obj = {};
            selObj.find("label").each(function () {
                tmp_obj = {'value' : ld(this).attr("value"),'text' : ld(this).text()};
                selObjinfo.push(tmp_obj);
            });
        }else if(datatype == 'text'){
            selObj.find("label").each(function () {
                selObjinfo.push(ld(this).text());
            });
        }else{
            selObj.find("label").each(function () {
                selObjinfo.push(ld(this).attr("value"));
            });
        }
        return selObjinfo;
    }
    //改变已隐藏的旧option，保证原先保存函数能够正常使用
    this.moveOption = function(srcObj,destObj) {
        cls_this.changeOption();
        var srcObj = srcObj.get(0);// $(source);
        var destObj = destObj.get(0);// $(destination);
        if(typeof(srcObj) == 'undefined' || typeof(destObj) == 'undefined') return;
        for(i=0;i<destObj.length;i++){
            destObj.options[i].selected=false;
        }
        for (i=0;i<srcObj.length;i++) {
            if (srcObj.options[i].selected==true) {
                var rowFound=false;
                var existingObj=null;
                for (j=0;j<destObj.length;j++) {
                    if (destObj.options[j].value==srcObj.options[i].value) {
                        srcObj.options.remove(i);//无论默认有无，都去掉该备选项 ,               
                        rowFound=true
                        existingObj=destObj.options[j]
                        break
                    }
                }
                if (rowFound!=true) {
                    var newColObj=document.createElement("OPTION")
                    newColObj.value=srcObj.options[i].value
                    if (browser_ie) 
                        newColObj.innerText=srcObj.options[i].innerText
                    else if (browser_nn4 || browser_nn6) 
                        newColObj.text=srcObj.options[i].text
                    destObj.appendChild(newColObj)//右键
                    srcObj.options[i].selected=false
                    srcObj.options.remove(i);
                    i=-1;
                    newColObj.selected=true
                    rowFound=false
                } else {
                    if(existingObj != null) 
                        existingObj.selected=true
                }
            }
        }
    }
    //改变新的input的选中状态时，同时改变已隐藏的option选中状态，为moveOption函数中可以移动旧数据
    this.changeOption = function(){
        cls_this.tableObj.find('#selectedAssmablyColumns_Right').find("input").each(function() {
            // 获取对应的label的value属性
            var labelValue = ld(this).siblings('label').attr('value');
            // 当input被选中时
            if (ld(this).is(":checked")) {
                // 根据该value属性找到select中对应的option并选中
                cls_this.original_tableObj.find('#'+ cls_this.ori_RightObjID +' option[value="' + labelValue + '"]').prop('selected', true);
                cls_this.original_tableObj.find('#'+ cls_this.ori_RightObjID).trigger('change');
            }else{
                cls_this.original_tableObj.find('#'+ cls_this.ori_RightObjID +' option[value="' + labelValue + '"]').prop('selected', false);
                cls_this.original_tableObj.find('#'+ cls_this.ori_RightObjID).trigger('change');
            }
        });
        cls_this.tableObj.find('#AssmablyList_Left').find("input").each(function() {
            var labelValue = ld(this).siblings('label').attr('value');
            if (ld(this).is(":checked")) {
                cls_this.original_tableObj.find('#'+ cls_this.ori_LeftObjID +' option[value="' + labelValue + '"]').prop('selected', true);
            }else{
                cls_this.original_tableObj.find('#'+ cls_this.ori_LeftObjID +' option[value="' + labelValue + '"]').prop('selected', false);
            }
        });
    }
    //用于显示隐藏字段时触发原select的onchange事件
    this.changeSingleOption = function(obj){
        // 获取对应的label的value属性
        var labelValue = ld(obj).siblings('label').attr('value');
        if (ld(obj).is(":checked")) {
            // 根据该value属性找到select中对应的option并选中
            cls_this.original_tableObj.find('#'+ cls_this.ori_RightObjID +' option[value="' + labelValue + '"]').prop('selected', true);
            cls_this.original_tableObj.find('#'+ cls_this.ori_RightObjID).trigger('change');
        }else{
            cls_this.original_tableObj.find('#'+ cls_this.ori_RightObjID +' option[value="' + labelValue + '"]').prop('selected', false);
            cls_this.original_tableObj.find('#'+ cls_this.ori_RightObjID).trigger('change');
        }
    }
}
DragTransfer.prototype.constructor = DragTransfer;

DragTransfer.prototype._instanceList = {};

/**
 * 获取单例
 * @param {jQuery} conJqObj 父元素DOM的jQuery对象
 * @return {DragTransfer} ChooseScope实例
 */
DragTransfer.getInstance = function (conJqObj) {
    conJqObj instanceof HTMLElement && ( conJqObj = ld(conJqObj) )
    if(!(conJqObj instanceof ld)) {
        console.error(new Error('conJqObj must be jQuery Obj'),conJqObj);
    }
    let instanceId = conJqObj.attr('_transfer_instance_');
    if(instanceId === null || typeof instanceId === "undefined"){
        instanceId = 'transfer_' + (new Date - 0);
        DragTransfer.prototype._instanceList[instanceId] = new DragTransfer();
        conJqObj.attr('_transfer_instance_',instanceId);
    }
    return DragTransfer.prototype._instanceList[instanceId];
}

DragTransfer.SetDragTransfer = function (conJqObj,option) {
    let instance = DragTransfer.getInstance(conJqObj);
    instance.SetTranslabel(option.transLabel);
    instance.need_resetLabelClick = option.need_resetLabelClick;
    instance.SetDragTransfer(conJqObj,option.left,option.right,option.type,option.width);
    return instance;
}