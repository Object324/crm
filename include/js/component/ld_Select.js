/**
 * @class  ld_Select
 * @author  hzx
 * @date  2023/11/30 - 初始版本
 * - 页签类
 * @description  下拉框 支持多选，单选以及固定选项
 */
function ld_Select(){
    var that = this;
    /**
     * 下拉选项数组
     * @type {Object.<selectData>|Array.<selectData>}
     */
    this.optionList = [];
    /**
     * 下拉框图标url
     * @type {string}
     */
    this.selecticonurl = '';
    /**
     * 下拉框悬浮图标url 鼠标悬浮在下拉框图标改变
     * @type {string}
     */
    this.selecticonhoverurl = '';

    /**
     * 点击下拉框选项回调事件
     * @type {function(evt)}
     */
    this.changeEvent = null;
    /**
     * 下拉框聚焦回调事件
     * @type {function(evt)}
     */
    this.blurEvent = null;
    /**
     * 下拉框失焦回调事件
     * @type {function(evt)}
     */
    this.focusEvent = null;

    /**
     * 下拉框宽度 适用css写法例如:px,css,calc()
     * @type {string}
     */
    this.width = '160px';
    /**
     * 固定下拉框宽度 适用css写法例如:px,css,calc()
     * @type {string}
     */
    this.fixwidth = '';
    /**
     * 下拉框内容最大宽度,溢出滚动
     * @type {num}
     */
    this.conheight = 300;

    /**
     * 是否是多选下拉框 默认是单选
     * @type {boolean}
     */
    this.multiple = false;


    this.placeholder = '请选择';

    /**
     * 下拉框固定列对象数组
     * @type {Array}
     */
    this.fixedoptions = [];

    /**
     * 下拉框容器的DOM对象
     * @type {HTMLElement}
     */
    this.LayoutObj = undefined;

    /**
     * 自定义class
     * @type {string}
     */
    this.classname = '';

    /**
     * 下拉框名称 如果空则为选中值
     * @type {string}
     */
    this.selectname = '';

    /**
     * 需要放入选项dom对象的data属性数组
     * @type {Array}
     */
    this.optionobjattr = [];

    /**
     * 下拉框内容显示类型
     * @type {string} hover为悬浮 click为点击
     */
    this.showtype = 'hover';

    /**
     * 下拉框内容宽度
     * @type {string}
     */
    this.optionwidth = '100%';

    /**
     * 是否可搜索，默认不可搜索，中文满足首字母搜索
     * @type {string}
     */
    this.filterable = false;

    /**
     * 下拉框靠左或靠右显示
     * @type {string}
     */
    this.showfloat = 'left';

    /**
     * 下拉框选项生成后回调事件
     * @type {function(evt)}
     */
    this.showselectafter = null;

    /**
     * 配置下拉框对象的实例
     * @param {HTMLElement} obj 放置下拉框的DOM对象
     * @param {Object.<selectData>|Array.<selectData>} selectData 下拉框的配置json
     */
    this.setSelect = function (obj,selectData){
        if(selectData.list && selectData.list.length > 0){
            that.optionList = selectData.list;
        }else{
            if(selectData.fixedoptions && selectData.fixedoptions.length > 0){}else{
                return false;
            }
        }
        if(selectData.selecticonurl){
            that.selecticonurl = selectData.selecticonurl;
        }
        if(selectData.selectname){
            that.selectname = selectData.selectname;
        }
        if(selectData.selecticonhoverurl){
            that.selecticonhoverurl = selectData.selecticonhoverurl;
        }
        if(selectData.width){
            that.width = selectData.width;
        }
        if(selectData.fixwidth){
            that.fixwidth = selectData.fixwidth;
        }
        if(selectData.conheight){
            that.conheight = selectData.conheight;
        }
        if(selectData.multiple){
            that.multiple = selectData.multiple;
        }
        this.LayoutObj = obj;

        if(selectData.change){
            that.changeEvent = selectData.change;
        }
        if(selectData.blur){
            that.blurEvent = selectData.blur;
        }
        if(selectData.focus){
            that.focusEvent = selectData.focus;
        }

        if(selectData.placeholder){
            that.placeholder = selectData.placeholder;
        }
        if(selectData.fixedoptions){
            that.fixedoptions = selectData.fixedoptions;
        }
        if(selectData.classname){
            that.classname = selectData.classname;
        }
        if(selectData.optionobjattr){
            that.optionobjattr = selectData.optionobjattr;
        }
        if(selectData.showtype){
            that.showtype = selectData.showtype;
        }
        if(selectData.optionwidth){
            that.optionwidth = selectData.optionwidth;
        }
        if(selectData.filterable){
            that.filterable = selectData.filterable;
        }
        if(selectData.showfloat){
            that.showfloat = selectData.showfloat;
        }
        if(selectData.showselectafter){
            that.showselectafter = selectData.showselectafter;
        }
        that.getSelectHtml();
        that.setAfterEvent();
    }

    /**
     * 生成下拉框html
     */
    this.getSelectHtml = function (){
        var selecthtml = '<div class="ld_Select-component '+that.classname+'" ';
        if(that.showfloat == 'right'){
            selecthtml += ' style="justify-content:flex-end;margin-right:20px;" ';
        }
        selecthtml +='tabindex="99">';

        var selectshowlabel = '';
        var selectedlabel = [];

        if(that.selectname == ''){
            selectshowlabel = that.placeholder;
            for(let i = 0;i<that.optionList.length;i++){
                if(that.optionList[i].selected){
                    selectedlabel.push(that.optionList[i].label);
                    if(!that.multiple){
                        break;
                    }
                }
            }
            if(selectedlabel.length > 0){
                selectshowlabel = selectedlabel.toString();
            }
        }else{
            selectshowlabel = that.selectname;
        }
        var labelMaxWidth = parseInt(that.width.split('px').shift());
        if(that.selecticonurl != ''){
            labelMaxWidth -= 60;
            selecthtml += '<div class="ld_Select-lefticon" style="background-image: url('+that.selecticonurl+')"></div>';
            selecthtml += '<div class="ld_Select-content " >';
            if(typeof iskehu001 !== "undefined" && iskehu001 != undefined && iskehu001 == 'yes'){
                selecthtml += '<span style="max-width: '+labelMaxWidth+'px;';
            }
            else{
                selecthtml += '<span title="'+selectshowlabel+'" style="max-width: '+labelMaxWidth+'px;';
            }
            if(that.fixwidth && that.fixwidth != ''){
                selecthtml += 'max-width: none;width: '+that.fixwidth+';';
            }
            selecthtml += '">'+selectshowlabel+'</span><b class="ld_Select_arrowicon"></b>' +
                '</div>';
        }else{
            labelMaxWidth -= 25;
            selecthtml += '<div class="ld_Select-content">' +
                    '<span style="max-width: '+labelMaxWidth+'px;';
            if(that.fixwidth && that.fixwidth != ''){
                selecthtml += 'max-width: none;width: '+that.fixwidth+';';
            }
            selecthtml += '">'+
                        selectshowlabel+
                    '</span>' +
                    '<b class="ld_Select_arrowicon"></b>' +
                '</div>';
        }

        // selecthtml += that.getSelectContentHtml();

        selecthtml += '</div>';

        var LayoutObj = that.LayoutObj;
        LayoutObj.innerHTML = selecthtml;
    }

    /**
     * 生成下拉框选项html
     */
    this.getSelectContentHtml = function(){
        var conheight = that.conheight;
        if(that.fixedoptions.length > 0){
            conheight = conheight - (that.fixedoptions.length * 36);
        }
        var optionlistbgobj = document.createElement('div');
        optionlistbgobj.className = 'ld_Select_optionlistbg';
        if(that.showfloat == 'right'){
            optionlistbgobj.className = 'ld_Select_optionlistbg ld_Select_optionlistbg_rightshow';
        }
        optionlistbgobj.style.width = that.optionwidth;
        var selectoptionhtml = '<div class="ld_Select-optionlist">';
        if(that.filterable){
            selectoptionhtml += '<div class="ld_select_searchdiv">' +
                '<input type="text" class="ld_select_searchinput" placeholder="'+arrJsPopLabel['SEARCHCAPITAL']+'"/>' +
                '<b style="position: absolute;right:9px;top:8px;cursor: pointer; display:none;" class="ld-icon-clearsearch"></b>'+
                '</div>'
        }
        selectoptionhtml += '<div class="ld_Select-option"><ul class="ld_Select-option-content" style="overflow: hidden auto;max-height: '+conheight+'px;';
        if(that.fixedoptions.length > 0){
            selectoptionhtml += 'padding-bottom: 8px;';
        }
        selectoptionhtml += '">';
        if(that.filterable){
            selectoptionhtml += '<li name="nocontent" title="'+arrJsPopLabel['NOMATCHINGITEMS']+'" style="display: none;"><div class="ld_Select-option-item">'+arrJsPopLabel['NOMATCHINGITEMS']+'</div></li>';
        }
        var optionList = that.optionList;

        var isselect = 'yes';
        for(let i = 0; i < optionList.length; i++){
            let attrStr = '';
            if(that.optionobjattr.length > 0){
                for(let j = 0;j<that.optionobjattr.length;j++){
                    if(that.optionList[i][that.optionobjattr[j]]){
                        attrStr += ' data-'+that.optionobjattr[j]+'="'+that.optionList[i][that.optionobjattr[j]]+'" ';
                    }
                }
            }
            var tip = empty(optionList[i].title)?optionList[i].label:optionList[i].title;
            if(typeof iskehu001 !== "undefined" && iskehu001 != undefined && iskehu001 == 'yes'){
                tip = '';
            }
            selectoptionhtml += '<li data-optionvalue="'+optionList[i].value+'" ' + attrStr + ' data-tip="'+tip+'" data-direction="top" data-type="position"';
            if(optionList[i].operations){
                selectoptionhtml += ' class="ld_select-optionopli" ';
            }
            selectoptionhtml += '><div class="ld_Select-option-item';
            if(that.multiple === true){
                selectoptionhtml += ' ld_Select-option-itemmult';
            }
            if(optionList[i].selected && isselect == 'yes'){
                selectoptionhtml += ' ld_Select-option-seleced';
                if(!that.multiple){
                    isselect = 'no';
                }
            }
            selectoptionhtml += '">';
            if(optionList[i].operations){
                selectoptionhtml += '<span>'+optionList[i].label+'</span>';
                if(optionList[i].operations.length > 0){
                    selectoptionhtml += '<div class="ld_select-option-operations">';
                    for(let op = 0;op < optionList[i].operations.length;op++){
                        selectoptionhtml += '<div class="ld_select-option-operation">'+optionList[i].operations[op].label+'</div>';
                    }
                    selectoptionhtml += '</div>';
                }
            }
            else{
                selectoptionhtml += '<span>'+optionList[i].label+'</span>';
            }
            selectoptionhtml += '</div></li>';

        }
        selectoptionhtml += '</ul>';

        if(that.fixedoptions.length > 0){
            selectoptionhtml += '<ul class="ld_select_fixedoption">';
            for(let i = 0;i<that.fixedoptions.length;i++){
                selectoptionhtml += '<li data-optiontype="fixed" data-fixedoptionindex="'+i+'"';
                if(that.fixedoptions[i].parameter){
                    selectoptionhtml += ' '+that.fixedoptions[i].parameter+' ';
                }
                selectoptionhtml += '><div class="fixedoption">';
                if(that.fixedoptions[i].iconurl && that.fixedoptions[i].iconurl != ''){
                    selectoptionhtml += '<i class="fixedoptionicon" style="background-image: url('+that.fixedoptions[i].iconurl+');"></i>';
                }
                selectoptionhtml += '<span>'+that.fixedoptions[i].label+'</span>' +
                    '</div></li>';
            }
            selectoptionhtml += '</ul>';
        }

        selectoptionhtml += '</div></div>'
        optionlistbgobj.innerHTML = selectoptionhtml;
        return optionlistbgobj;
    }

    /**
     * 页面渲染html后操作
     */
    this.setAfterEvent = function(){
        var ld_Select_obj = that.LayoutObj.querySelector('.ld_Select-component');
        that.ld_Select_obj = ld_Select_obj;

        if(that.selecticonurl != '' && that.selecticonhoverurl != ''){
            ld_Select_obj.addEventListener('mouseenter',function (){
                ld_Select_obj.querySelector('.ld_Select-lefticon').style.backgroundImage = 'url('+that.selecticonhoverurl+')';
            });
            ld_Select_obj.addEventListener('mouseleave',function (){
                ld_Select_obj.querySelector('.ld_Select-lefticon').style.backgroundImage = 'url('+that.selecticonurl+')';
            });
        }

        if(that.showtype == 'hover'){
            ld_Select_obj.addEventListener('mouseenter',that.showOptionListBg);
            ld_Select_obj.addEventListener('mouseleave',function (){
                that.ld_Select_obj.querySelector('.ld_Select-content b.ld_Select_arrowicon').className = 'ld_Select_arrowicon';
                if(ld_Select_obj.querySelector('.ld_Select_optionlistbg') != null){
                        ld_Select_obj.querySelector('.ld_Select_optionlistbg').style.display = 'none';
                }
            });
        }
        else if(that.showtype == 'click'){
            ld_Select_obj.addEventListener('click',that.showOptionListBg);
            //document.addEventListener('click', that.clickblackfun);
        }
    }

    this.clickblackfun = function () {
        var isClickInside = that.ld_Select_obj.contains(event.target);
        if (!isClickInside) {
            that.ld_Select_obj.querySelector('.ld_Select-content b.ld_Select_arrowicon').className = 'ld_Select_arrowicon';
            if(that.ld_Select_obj.querySelector('.ld_Select_optionlistbg') != null){
                that.ld_Select_obj.querySelector('.ld_Select_optionlistbg').style.display = 'none';
                document.removeEventListener('mouseup', that.clickblackfun);
            }
        }
    }

    /**
     * 显示下拉框内容
     */
    this.showOptionListBg = function(){
        if(that.ld_Select_obj.querySelector('.ld_Select_optionlistbg') == null){
            that.ld_Select_obj.querySelector('.ld_Select-content b.ld_Select_arrowicon').className = 'ld_Select_arrowicon activeicon';
            var optionlistbgobj = that.getSelectContentHtml();
            that.ld_Select_obj.querySelector('.ld_Select-content').after(optionlistbgobj);
            if(that.showtype == 'click'){
                document.addEventListener('mouseup', that.clickblackfun);
            }
            var optionlistliobj = that.ld_Select_obj.querySelectorAll('.ld_Select-optionlist ul li');
            if(that.filterable && that.ld_Select_obj.querySelector('.ld_select_searchinput') != null){
                var list_optionlist_ulobj = that.ld_Select_obj.querySelector('.ld_Select-optionlist .ld_Select-option ul');
                list_optionlist_ulobj.style.height = list_optionlist_ulobj.offsetHeight+'px';
                var searchinput_obj = that.ld_Select_obj.querySelector('.ld_select_searchinput');
                searchinput_obj.addEventListener('keyup',that.selectSearchEvent);
            }
            for(let i = 0;i<optionlistliobj.length;i++){
                if(optionlistliobj[i].getAttribute('name') != 'nocontent'){
                    that.bindOptionEvent(optionlistliobj[i]);
                }
            }
            var optionfixedlistliobj = that.ld_Select_obj.querySelectorAll('.ld_Select-optionlist ul.ld_select_fixedoption li');
            for(let i = 0;i<optionfixedlistliobj.length;i++){
                if(that.fixedoptions[i] && that.fixedoptions[i].iconurl && that.fixedoptions[i].iconhoverurl){
                    optionfixedlistliobj[i].addEventListener('mouseover',function(){
                        this.querySelector('i.fixedoptionicon').style.backgroundImage = 'url('+that.fixedoptions[i].iconhoverurl+')';
                    });
                    optionfixedlistliobj[i].addEventListener('mouseout',function(){
                        this.querySelector('i.fixedoptionicon').style.backgroundImage = 'url('+that.fixedoptions[i].iconurl+')';
                    });
                }
            }
            if(that.showselectafter != null){
                that.showselectafter();
            }
        }
        else{
            that.ld_Select_obj.querySelector('.ld_Select-content b.ld_Select_arrowicon').className = 'ld_Select_arrowicon';
            if(that.ld_Select_obj.querySelector('.ld_Select_optionlistbg') != null){
                if(that.ld_Select_obj.querySelector('.ld_Select_optionlistbg').style.display == 'none'){
                    that.ld_Select_obj.querySelector('.ld_Select-content b.ld_Select_arrowicon').className = 'ld_Select_arrowicon activeicon';
                    that.ld_Select_obj.querySelector('.ld_Select_optionlistbg').style.display = '';
                    if(that.showtype == 'click'){
                        document.addEventListener('mouseup', that.clickblackfun);
                    }
                }else{
                    if(event.target.nodeName == 'INPUT' && event.target.className == 'ld_select_searchinput'){

                    }else{
                        that.ld_Select_obj.querySelector('.ld_Select_optionlistbg').style.display = 'none';
                        if(that.showtype == 'click'){
                            document.removeEventListener('mouseup', that.clickblackfun);
                        }
                    }

                }
            }
        }
        if(typeof tooltip === "function"){
            tooltip(that.ld_Select_obj.querySelectorAll('.ld_Select-option-content li'), {transition: true, time: 200});
        }
    }

    /**
     * 选项点击绑定事件
     */
    this.bindOptionEvent = function(optionitems){
        optionitems.addEventListener('click',that.optionLiobjEvent);
    }

    /**
     * 清除搜索事件
     */
    this.clearSearch = function(){
        event.stopPropagation();
        var clearsearchobj = that.ld_Select_obj.querySelector('.ld-icon-clearsearch');
        var searchinput_obj = that.ld_Select_obj.querySelector('.ld_select_searchinput');
        if(clearsearchobj != null){
            clearsearchobj.style.display = 'none';
            searchinput_obj.value = '';
            searchinput_obj.focus();
            var optionlistliobj = that.ld_Select_obj.querySelectorAll('.ld_Select-optionlist ul li');
            for(let i = 0;i<optionlistliobj.length;i++){
                if(optionlistliobj[i].getAttribute('name') == 'nocontent'){
                    optionlistliobj[i].style.display = 'none';
                    continue;
                }
                optionlistliobj[i].style.display = '';
            }
        }
    }
    /**
     * 搜索框绑定事件
     */
    this.selectSearchEvent = function(e){
        var optionlistliobj = that.ld_Select_obj.querySelectorAll('.ld_Select-optionlist ul li');
        var searchtext = this.value;
        var clearsearchobj = that.ld_Select_obj.querySelector('.ld-icon-clearsearch');
        if(clearsearchobj != null){
            if(trim(searchtext) == '')
            {
                clearsearchobj.style.display = 'none';
            }else{
                clearsearchobj.style.display = 'block';
                clearsearchobj.addEventListener('click',that.clearSearch);
            }
        }
        var keyCode = e.keyCode || e.which || e.charCode;
        var ctrlKey = e.ctrlKey || e.metaKey;
        if(ctrlKey && (keyCode==13||keyCode==10)){

        }
        else if(ctrlKey)
        {
        }
        else if(keyCode==13)
        {
        }
        else{
            getJsScript('include/js/multipingyin.js',function(){
                searchtext=searchtext.replace(/<br>/ig,'');
                if(trim(searchtext)=='')
                {
                    searchtext = '';
                }
                var uppersearch=searchtext.toLowerCase();
                var b=false;

                for(let i = 0;i<optionlistliobj.length;i++){
                    if(optionlistliobj[i].getAttribute('name') == 'nocontent'){
                        continue;
                    }
                    var text=optionlistliobj[i].textContent.toLowerCase();
                    var arrRslt = makePy(text);
                    if(arrRslt != undefined){
                        var pingyingstr=arrRslt.join("").toLowerCase();
                        if(text.indexOf(uppersearch)>=0||pingyingstr.indexOf(uppersearch)>=0)
                        {
                            b=true;
                            optionlistliobj[i].style.display = '';
                        }
                        else
                        {
                            optionlistliobj[i].style.display = 'none';
                        }
                    }
                }
                if(b == false){
                    that.ld_Select_obj.querySelector('.ld_Select-optionlist ul li[name=nocontent]').style.display = 'block';
                }else{
                    that.ld_Select_obj.querySelector('.ld_Select-optionlist ul li[name=nocontent]').style.display = 'none';
                }
            });
        }
    }

    this.getParentByClassName =function(element, tagName) {
        while (element.parentNode) {
            element = element.parentNode;
            if (element.tagName == tagName) {
                return element;
            }
        }
        return null; // 没有找到匹配的父元素
    }

    /**
     * 单选多选状态修改
     */
    this.optionLiobjEvent = function(){
        event.stopPropagation();
        var obj;
        if(event.target.tagName == 'LI'){
            obj = event.target;
        }else{
            /*if(event.target.parentNode.tagName == 'LI'){
                obj = event.target.parentNode;
            }else{
                obj = event.target.parentNode.parentNode;
            }*/
            obj = that.getParentByClassName(event.target,'LI');
        }
        if(obj == null){
            return;
        }
        //固定列点击事件
        if(obj.getAttribute('data-optiontype') == 'fixed'){
            var fixedoptionindex = obj.getAttribute('data-fixedoptionindex');
            that.ld_Select_obj.querySelector('.ld_Select-content b.ld_Select_arrowicon').className = 'ld_Select_arrowicon';
            var ld_Selectcontent_obj = that.ld_Select_obj.querySelector('.ld_Select_optionlistbg');
            if(ld_Selectcontent_obj != null){
                ld_Selectcontent_obj.style.display = 'none';
                if(that.showtype == 'click'){
                    document.removeEventListener('mouseup', that.clickblackfun);
                }
            }
            if(that.fixedoptions[fixedoptionindex].clickevent){
                var Event = {};
                var NavBarItemlist = that.fixedoptions[fixedoptionindex];
                Event['target'] = obj;
                Event['NavBarItem'] = NavBarItemlist;
                that.fixedoptions[fixedoptionindex].clickevent(Event);
            }
        }
        //下拉框点击事件
        else{
            var havechange = that.changeOptionSelectedStatus(obj);
            if(that.changeEvent != null){
                var Event = {};
                //多选
                if(that.multiple) {
                    var targetlist = [];
                    var NavBarItemlist = [];
                    var selectlist = this.parentNode.querySelectorAll('.ld_Select-option-seleced');
                    var tmp_optionvalue = '';
                    for(let i = 0;i < selectlist.length;i++){
                        targetlist.push(selectlist[i].parentNode);
                        tmp_optionvalue = selectlist[i].parentNode.getAttribute('data-optionvalue');
                        for(let j = 0;j < that.optionList.length;j++){
                            if(tmp_optionvalue == that.optionList[j].value){
                                NavBarItemlist.push(that.optionList[j]);
                                break;
                            }
                        }
                    }
                    Event['target'] = targetlist;
                    Event['NavBarItem'] = NavBarItemlist;
                    Event['changeItem'] = obj;
                }
                //单选
                else{
                    if(havechange == 'yes'){
                        var optionvalue = obj.getAttribute('data-optionvalue');
                        for (let i = 0; i < that.optionList.length; i++) {
                            if (optionvalue == that.optionList[i].value) {
                                Event['target'] = obj;
                                Event['NavBarItem'] = that.optionList[i];
                                break;
                            }
                        }
                        that.ld_Select_obj.querySelector('.ld_Select-content b.ld_Select_arrowicon').className = 'ld_Select_arrowicon';
                        var ld_Selectcontent_obj = that.LayoutObj.querySelector('.ld_Select-component .ld_Select_optionlistbg');
                        if(that.LayoutObj.querySelector('.ld_Select-component .ld_Select-lefticon') != null){
                            that.LayoutObj.querySelector('.ld_Select-component .ld_Select-lefticon').style.backgroundImage = 'url('+that.selecticonurl+')';
                        }
                        if(ld_Selectcontent_obj != null){
                            ld_Selectcontent_obj.style.display = 'none';
                            if(that.showtype == 'click'){
                                document.removeEventListener('mouseup', that.clickblackfun);
                            }
                        }
                    }else{
                        return ;
                    }
                }
                that.changeEvent(Event);
            }
        }
    }

    /**
     * 单选多选状态修改
     */
    this.changeOptionSelectedStatus = function(optionobj){
        var havechange = 'yes';
        var optionvalue = optionobj.getAttribute('data-optionvalue');
        var selectedlabel = [];
        //多选
        if(that.multiple){
            if(optionobj.querySelector('.ld_Select-option-seleced') == null){
                optionobj.querySelector('.ld_Select-option-item').className = 'ld_Select-option-item ld_Select-option-itemmult ld_Select-option-seleced';
            }else{
                optionobj.querySelector('.ld_Select-option-item').className = 'ld_Select-option-item ld_Select-option-itemmult';
            }
            for(let i = 0;i<that.optionList.length;i++){
                if(that.optionList[i].value == optionvalue){
                    if(that.optionList[i].selected){
                        that.optionList[i].selected = false;
                    }else{
                        that.optionList[i].selected = true;
                    }
                }
                if(that.optionList[i].selected){
                    selectedlabel.push(that.optionList[i].label);
                }
            }
        }
        //单选
        else{
            if(optionobj.querySelector('.ld_Select-option-seleced') == null){
                var b_selectlist = optionobj.parentNode.querySelectorAll('.ld_Select-option-seleced');
                for(let i = 0;i<b_selectlist.length;i++){
                    b_selectlist[i].className = 'ld_Select-option-item';
                }
                optionobj.querySelector('.ld_Select-option-item').className = 'ld_Select-option-item ld_Select-option-seleced';
            }else {
                havechange = 'yes';
            }
            for(let i = 0;i<that.optionList.length;i++){
                if(that.optionList[i].value == optionvalue){
                    that.optionList[i].selected = true;
                    selectedlabel = [that.optionList[i].label];
                }else{
                    that.optionList[i].selected = false;
                }
            }
        }
        if(that.selectname == ''){
            var ld_Select_obj = that.LayoutObj.querySelector('.ld_Select-component');
            var selectlabelobj = ld_Select_obj.querySelector('.ld_Select-content span');
            if(selectedlabel.length == 0){
                selectlabelobj.innerHTML = that.placeholder;
                selectlabelobj.setAttribute('title',that.placeholder);
            }else{
                selectlabelobj.innerHTML = selectedlabel.toString();
                if(typeof iskehu001 !== "undefined" && iskehu001 != undefined && iskehu001 == 'yes'){

                }
                else{
                    selectlabelobj.setAttribute('title',selectedlabel.toString());
                }

            }

        }
        return havechange;
    }

    this.eventChangeSelected = function (index) {
        // 创建一个 click 事件
        var clickevent = new MouseEvent('click', {
            'view': window,
            'bubbles': true,
            'cancelable': true
        });
        if(that.ld_Select_obj.querySelector('.ld_Select_optionlistbg') != null){
            var optionlistliobj = that.ld_Select_obj.querySelectorAll('.ld_Select-optionlist ul li');
            if(optionlistliobj[0].getAttribute('name') == 'nocontent'){
                optionlistliobj[index+1].dispatchEvent(clickevent);
            }else{
                optionlistliobj[index].dispatchEvent(clickevent);
            }

        }else{
            var optionlistbgobj = that.getSelectContentHtml();
            optionlistbgobj.style.display = 'none';
            if(that.showtype == 'click'){
                document.removeEventListener('mouseup', that.clickblackfun);
            }
            that.ld_Select_obj.querySelector('.ld_Select-content').after(optionlistbgobj);
            var optionlistliobj = that.ld_Select_obj.querySelectorAll('.ld_Select-optionlist ul li');
            if(that.filterable && that.ld_Select_obj.querySelector('.ld_select_searchinput') != null){
                var list_optionlist_ulobj = that.ld_Select_obj.querySelector('.ld_Select-optionlist .ld_Select-option ul');
                list_optionlist_ulobj.style.height = '300px';
                var searchinput_obj = that.ld_Select_obj.querySelector('.ld_select_searchinput');
                searchinput_obj.addEventListener('keyup',that.selectSearchEvent);
            }
            for(let i = 0;i<optionlistliobj.length;i++){
                if(optionlistliobj[i].getAttribute('name') != 'nocontent'){
                    that.bindOptionEvent(optionlistliobj[i]);
                }

            }
            var optionfixedlistliobj = that.ld_Select_obj.querySelectorAll('.ld_Select-optionlist ul.ld_select_fixedoption li');
            for(let i = 0;i<optionfixedlistliobj.length;i++){
                if(that.fixedoptions[i] && that.fixedoptions[i].iconurl && that.fixedoptions[i].iconhoverurl){
                    optionfixedlistliobj[i].addEventListener('mouseover',function(){
                        this.querySelector('i.fixedoptionicon').style.backgroundImage = 'url('+that.fixedoptions[i].iconhoverurl+')';
                    });
                    optionfixedlistliobj[i].addEventListener('mouseout',function(){
                        this.querySelector('i.fixedoptionicon').style.backgroundImage = 'url('+that.fixedoptions[i].iconurl+')';
                    });
                }
            }
            var optionlistliobj = that.ld_Select_obj.querySelectorAll('.ld_Select-optionlist ul li');
            if(optionlistliobj[0].getAttribute('name') == 'nocontent'){
                optionlistliobj[index+1].dispatchEvent(clickevent);
            }else{
                optionlistliobj[index].dispatchEvent(clickevent);
            }
        }
    }
}

/**
 * 创建一个ld_Select实例
 * @param {HTMLElement} obj 放置下拉框的DOM对象
 * @param {Object.<selectData>|Array.<selectData>} selectData 下拉框配置JSON
 * @return {ld_Select} ld_Select实例
 * @example
 * - ld_NavBar.showSelect(LayoutObj,selectData);
 */
ld_Select.showSelect = function (obj,selectData){
    var ld_Selectobj = new ld_Select();
    ld_Selectobj.setSelect(obj,selectData);
    return ld_Selectobj;
}