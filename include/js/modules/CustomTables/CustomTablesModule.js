function CustomTablesModule(){
    var that=this;
    that.pageto_module = 'ReportAnalysis';
    that.report_id = '';//报表ID
    that.popupobj = '';//弹框对象

    //点击下一步的时候 判断是否要清空字段 应当有如下判断
    //1.主模块变化  以前选择的字段应当全部清空
    //2.其他情况下啊 对应模块变化应当清空对应模块的字段


    that.init = function(popupobj){
        that.popupobj=popupobj;
        that.PopupJqObj = ld('#'+that.popupobj.divid);
    }
    that.setData = function(data){
        if(typeof that.data === "object")
            Object.assign(that.data,data);
        else
            that.data = data;
    }
    that.getRecursionModuleArr = function(report_id,callback){
        var url = "index.php?module="+that.pageto_module+"&action="+that.pageto_module+"Ajax&file=ModuleInfo&function_name=getRecursionModuleArr&report_id="+report_id;
        ldAjaxNoProgress(url,{},function(data) {
            that.setData(data.result);
            that.show();
            callback(data.result);
        });
    }
    //显示选模块页面内容
    that.show = function(){
        var width = ld(window).width()*0.85;

        var pophtml = '<div id="module_all_select" class="ld-flex-between" style="width:'+width+'px;overflow-x: auto;padding:20px 0;">\n' +
            '            <div style="min-width:calc(50% - 100px);flex-shrink: 0;" class="ld-flex-end" id="module_all_select_prev">\n' +
            '            </div>\n' +
            '            <div style="flex-shrink: 0;" class="width200" id="module_all_select_mainmodule">\n' +
            that.getMainModuleHtml() +
            '            </div>\n' +
            '            <div style="min-width:calc(50% - 100px);flex-shrink: 0;" class="ld-flex-start" id="module_all_select_next">\n' +
            '        </div>';
        that.PopupJqObj.find('#changeModuleNamesTd').html(pophtml);
        //初始选择--去掉 20240913 BUG20240912-18
        //that.mainmoduleChange(that.PopupJqObj.find('#mainmodule'));
        //主模块下拉框双向绑定
        that.setMainmoduleBind();
        //主模块下拉框 变成可搜索下拉框
        that.resetComboxHtml(that.PopupJqObj.find('#changeModuleNamesTd #mainmodule'));
        //绑定主模块切换事件
        that.PopupJqObj.find('#mainmodule').unbind('change').bind('change',function(){
            that.data.prevSelectedArr=[];//主模块变化  将上下游全部清空
            that.data.nextSelectedArr=[];
            that.mainmoduleChange(this);
        });
        that.renderChildselect();
    }
    that.setMainmoduleBind = function(){
        if(!that.DataHtmlBindObj)
            that.DataHtmlBindObj = new DataHtmlBind();
        var JqueryObj = that.PopupJqObj.find('#module_all_select #mainmodule');
        if(JqueryObj.length > 0)
            that.DataHtmlBindObj.setDataBindByJqObj(JqueryObj,that.data,'mainmoduleSelected');
    }
    that.setChildModuleBind=function(type,index){
        if(!that.DataHtmlBindObj)
            that.DataHtmlBindObj = new DataHtmlBind();
        var JqueryObj = that.PopupJqObj.find('#module_all_select #'+type+'Module'+index);
        if(JqueryObj.length > 0)
            that.DataHtmlBindObj.setDataBindByJqObj(JqueryObj,that.data[type+'SelectedArr'][index],'selectmodule');
    }
    that.mainmoduleChange = function(obj){
        //前后两个下拉框全清空
        that.PopupJqObj.find('#module_all_select_prev').empty();
        that.PopupJqObj.find('#module_all_select_next').empty();
        //重新生成前后两个下拉框
        var modulename = ld(obj).val();

        that.getRelatedModule('all',modulename,function(data){
            if(data.result.PrevModules&&data.result.PrevModules.length>0){
                var prevHtml = that.getPrevHtml(data.result.PrevModules,0);
                that.PopupJqObj.find('#module_all_select_prev').prepend(prevHtml);
                that.resetComboxHtml(that.PopupJqObj.find('#changeModuleNamesTd #prevModule0'));
            }

            //上游模块双向绑定  以及往数组中加值
            if(!that.data.prevSelectedArr[0]){
                that.data.prevSelectedArr.push({'selectmodule':''});
            }
            that.setChildModuleBind('prev',0);
            var firstPrevModule = that.PopupJqObj.find('#prevModule0');
            //绑定上游模块切换事件
            firstPrevModule.unbind('change').bind('change',function(){
                that.prevmoduleChange(this);
            });
            if(!empty(firstPrevModule.val()))
                that.prevmoduleChange(firstPrevModule.get(0));

            if(data.result.NextModules&&data.result.NextModules.length>0) {
                var nextHtml = that.getNextHtml(data.result.NextModules, 0);
                that.PopupJqObj.find('#module_all_select_next').append(nextHtml);
                that.resetComboxHtml(that.PopupJqObj.find('#changeModuleNamesTd #nextModule0'));
            }
            //上游模块双向绑定  以及往数组中加值
            if(!that.data.nextSelectedArr[0]) {
                that.data.nextSelectedArr.push({'selectmodule': ''});
            }
            that.setChildModuleBind('next',0);
            var firstNextModule = that.PopupJqObj.find('#nextModule0');
            //绑定下游模块切换事件
            firstNextModule.unbind('change').bind('change',function(){
                that.nextmoduleChange(this);
            });
            if(!empty(firstNextModule.val()))
                that.nextmoduleChange(firstNextModule.get(0));
        });
    }
    that.prevmoduleChange = function(obj){
        var curindex = ld(obj).attr('selectindex');
        var nextindex = parseInt(curindex)+1;
        var modulename = ld(obj).val();
        that.PopupJqObj.find('#module_all_select_prev').find('.ld-customtable-selectdiv[selectindex='+curindex+']').prevAll().remove();
        // that.data.prevSelectedArr.splice(curindex);
        that.getRelatedModule('prev',modulename,function(data) {
            if(data.result.PrevModules&&data.result.PrevModules.length>0) {
                var prevHtml = that.getPrevHtml(data.result.PrevModules, nextindex);
                that.PopupJqObj.find('#module_all_select_prev').prepend(prevHtml);
                that.resetComboxHtml(that.PopupJqObj.find('#changeModuleNamesTd #prevModule' + nextindex));
            }
            //上游模块双向绑定  以及往数组中加值
            if(!that.data.prevSelectedArr[nextindex]) {
                that.data.prevSelectedArr.push({'selectmodule':''});
            }
            that.setChildModuleBind('prev',nextindex);
            //绑定上游模块切换事件
            that.PopupJqObj.find('#prevModule'+nextindex).unbind('change').bind('change', function () {
                that.prevmoduleChange(this);
            });
        });
    }
    that.nextmoduleChange = function(obj){
        var curindex = ld(obj).attr('selectindex');
        var nextindex = parseInt(curindex)+1;
        var modulename = ld(obj).val();
        that.PopupJqObj.find('#module_all_select_next').find('.ld-customtable-selectdiv:gt('+curindex+')').remove();
        // that.data.nextSelectedArr.splice(curindex);
        that.getRelatedModule('next',modulename,function(data) {
            if(data.result.NextModules&&data.result.NextModules.length>0) {
                var nextHtml = that.getNextHtml(data.result.NextModules, nextindex);
                that.PopupJqObj.find('#module_all_select_next').append(nextHtml);
                that.resetComboxHtml(that.PopupJqObj.find('#changeModuleNamesTd #nextModule' + nextindex));
            }
            if(!that.data.nextSelectedArr[nextindex]) {
                that.data.nextSelectedArr.push({'selectmodule':''});
            }
            that.setChildModuleBind('next',nextindex);
            //绑定上游模块切换事件
            that.PopupJqObj.find('#nextModule'+nextindex).unbind('change').bind('change', function () {
                that.nextmoduleChange(this);
            });
        });
    }
    that.renderChildselect = function(){
        //主模块 show里面已经渲染
        //循环下游模块
        if(that.data.nextArr&&that.data.nextArr.length>0){
            ld.each(that.data.nextArr,function(index,item){
                if(that.PopupJqObj.find('#nextModule'+index).length <= 0){
                    var nextHtml = that.getNextHtml(item,index);
                    that.PopupJqObj.find('#module_all_select_next').append(nextHtml);
                    that.resetComboxHtml(that.PopupJqObj.find('#changeModuleNamesTd #nextModule'+index));
                    that.setChildModuleBind('next',index);
                    //绑定下游模块切换事件
                    that.PopupJqObj.find('#nextModule'+index).unbind('change').bind('change',function(){
                        that.nextmoduleChange(this);
                    });
                }
            });
        }

        //上游
        if(that.data.prevArr&&that.data.prevArr.length>0) {
            ld.each(that.data.prevArr, function (index, item) {
                if(that.PopupJqObj.find('#prevModule'+index).length <= 0) {
                    var prevHtml = that.getPrevHtml(item, index);
                    that.PopupJqObj.find('#module_all_select_prev').prepend(prevHtml);
                    that.resetComboxHtml(that.PopupJqObj.find('#changeModuleNamesTd #prevModule'+index));
                    that.setChildModuleBind('prev', index);
                    //绑定下游模块切换事件
                    that.PopupJqObj.find('#prevModule' + index).unbind('change').bind('change', function () {
                        that.prevmoduleChange(this);
                    });
                }
            });
        }

    }
    //获取模块 应当有几个参数控制  1.获取所有模块 parent_id=0 2.主模块选中的时候 需要获取主模块的上下游模块 parent_id>0且pathtype=all 3.上游模块选中获取上游模块 parent_id>0且pathtype=prev 4.下游模块选中获取下游模块 parent_id>0且pathtype=next
    that.getRelatedModule = function(pathtype,modulename,callback){
        var url = "index.php?module="+that.pageto_module+"&action="+that.pageto_module+"Ajax&file=ModuleInfo&function_name=getRelatedModule&pathtype="+pathtype+"&modulename="+modulename;
        var params = {};
        params['mainmoduleSelected'] = that.data.mainmoduleSelected;
        params['nextSelectedArr'] = JSON.stringify(that.data.nextSelectedArr);
        params['prevSelectedArr'] = JSON.stringify(that.data.prevSelectedArr);
        ldAjaxNoProgress(url,params,function(data) {
            callback(data);
        });
    }
    //根据模块获取所有的字段信息
    that.getModuleAllFields = function(report_id,callback){
        var url = "index.php?module="+that.pageto_module+"&action="+that.pageto_module+"Ajax&file=ModuleInfo&function_name=getModuleFields";
        var params = {};
        params['report_id'] = report_id;
        params['mainmoduleSelected'] = that.data.mainmoduleSelected;
        params['nextSelectedArr'] = JSON.stringify(that.data.nextSelectedArr);
        params['prevSelectedArr'] = JSON.stringify(that.data.prevSelectedArr);
        ldAjaxNoProgress(url,params,function(data) {
            that.setData(data.result);
            that.show();
            callback(data.result);
        });
    }
	//获取主模块下拉框
    that.getMainModuleHtml = function(){
        var mainmoduleArr = that.data.mainmoduleArr;
        that.mainmoduleList = mainmoduleArr;
        return that.getselectHtml('mainmodule',mainmoduleArr,0);
    }
	//获取上游模块下拉框
    that.getPrevHtml = function(PrevModules,previndex){
        return that.getselectHtml('prev',PrevModules,previndex);
    }
	//获取下游模块下拉框
    that.getNextHtml = function(NextModules,nextindex){
        return that.getselectHtml('next',NextModules,nextindex);
    }
    //获取模块下拉框html
    that.getselectHtml = function(type,moduleArr,index){
        var idname = '';
        var larrow = '';
        var rarrow = '';
        var widthclass = 'gwidth90';
        if(empty(moduleArr)||moduleArr.length<=0||moduleArr==undefined){
            return '';
        }
        if(type=='mainmodule'){
            idname = 'mainmodule';
            widthclass = 'gwidth100';
        }
        if(type=='prev'){
            idname = 'prevModule'+index;
            rarrow = '<div class="hlineheight30"><span class="greyFont9 marLR5">&lt;</span></div>';
        }
        if(type=='next'){
            idname = 'nextModule'+index;
            larrow = '<div class="hlineheight30"><span class="greyFont9 marLR5">&gt;</span></div>';
        }
        var html ='<div style="flex-shrink: 0;" class="width200 ld-flex-between ld-customtable-selectdiv" selectindex="'+index+'">\n' +larrow+
            '                        <div><select selectindex="'+index+'" id="'+idname+'" name="'+idname+'" class="ld-select-inner width180 '+widthclass+' overflow-space">\n';
        if(type!='mainmodule') {
            html += '     <option value="">\n' + arrJsPopLabel['pleaseselect']+
                '                        </option>';
        }
        ld.each(moduleArr,function(tabid,tabinfo){
            var selected="";
            if(tabinfo.selected=='yes'){
                selected='selected';
            }
            html += '     <option '+selected+' value="'+tabinfo.modulename+'">\n' +tabinfo.modulelabel +
                '                        </option>';
        });
        html += '     </select></div>\n' + rarrow+
            '                        </div>';
        return html;
    }
    that.resetComboxHtml = function(obj){
        var cls_resetComboxHtmlobj=new cls_resetComboxHtml(ld(obj).attr("name"));
        cls_resetComboxHtmlobj.setPopupObj(that.popupobj);
        cls_resetComboxHtmlobj.setSearchComboxWidthByhtml(ld(obj),180);
    }
}