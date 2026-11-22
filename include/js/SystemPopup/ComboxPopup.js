//下拉框编辑弹出层
function ComboxPopup()
{
    
    var parentshow=this.show;
    var that=this;
     this.show=function(htmlcontent)
    {
           
             parentshow.apply(this,[htmlcontent]);  //调用父类show()函数

             ////设置当前弹出的高度
            // document.getElementById(this.divid).style.height="50%";
             
    }
     //隐藏首末排序的上移下移
    this.hidesort=function(){
        var popupobj=CrmPopup.getPopupObj("last");
        ld('#'+popupobj.divid+' .sort_td').children("a").show();
        ld('#'+popupobj.divid+' .sort_td:not(.dragings):first').children("a:first").hide();
        ld('#'+popupobj.divid+' .sort_td:not(.dragings):last').children("a:eq(1)").hide();
    }
    
    //上移
    this.moveUp=function(obj){
        this.moveoperate(obj,'moveup');
    }
    //下移
    this.moveDown=function(obj){
        this.moveoperate(obj,'movedown');
    }
    this.moveoperate = function(obj,type){
        //BUG0066956 duan 20230526 原来的逻辑太乱了,重新写
        //交换下拉框选项的值
        if(type == 'moveup'){
            var cur_trobj = ld(obj).parents('tr');//当前行
            var prev_trobj = cur_trobj.prev();//上一行
        }else{
            var prev_trobj = ld(obj).parents('tr');//当前行
            var cur_trobj = prev_trobj.next();//下一行
        }
        var selfinput = cur_trobj.find('input[tag=combox]');
        var upinput = prev_trobj.find('input[tag=combox]');
        //获取上下行的值
        var selfval = ld(selfinput).val();
        var selfname = ld(selfinput).attr('name');
        var selfold = ld(selfinput).attr('oldvalue');
        var upval = ld(upinput).val();
        var upname = ld(upinput).attr('name');
        var upold = ld(upinput).attr('oldvalue');
        //重新赋值
        ld(selfinput).val(upval);
        ld(selfinput).attr('name',upname);
        ld(selfinput).attr('oldvalue',upold);
        ld(upinput).val(selfval);
        ld(upinput).attr('name',selfname);
        ld(upinput).attr('oldvalue',selfold);

        //销售机会-sale_stage字段需要增加'赢率'
        var selfinput_winrate = cur_trobj.find('input[name="set_winrate"]');
        var upinput_winrate = prev_trobj.find('input[name="set_winrate"]');
        if(selfinput_winrate.length >0 && upinput_winrate.length >0){
            //获取上下行的值
            var selfval_winrate = ld(selfinput_winrate).val();
            var selftag_winrate = ld(selfinput_winrate).attr('tag');
            var upval_winrate = ld(upinput_winrate).val();
            var uptag_winrate = ld(upinput_winrate).attr('tag');
            //重新赋值
            ld(selfinput_winrate).val(upval_winrate);
            ld(selfinput_winrate).attr('tag',uptag_winrate);
            ld(upinput_winrate).val(selfval_winrate);
            ld(upinput_winrate).attr('tag',selftag_winrate);
        }

         //wym 240321 XUQIU20240204-09 销售线索可编辑追踪字段
        var selfinput_mapmodule = cur_trobj.find('input[name="set_mapmodule"]');
        var upinput_mapmodule = prev_trobj.find('input[name="set_mapmodule"]');
        if(selfinput_mapmodule.length >0 && upinput_mapmodule.length >0){
            var selfval_mapmodule = ld(selfinput_mapmodule).val();
            var selftag_mapmodule = ld(selfinput_mapmodule).attr('tag');
            var upval_mapmodule = ld(upinput_mapmodule).val();
            var uptag_mapmodule = ld(upinput_mapmodule).attr('tag');
            ld(selfinput_mapmodule).val(upval_mapmodule);
            ld(selfinput_mapmodule).attr('tag',uptag_mapmodule);
            ld(upinput_mapmodule).val(selfval_mapmodule);
            ld(upinput_mapmodule).attr('tag',selftag_mapmodule);
        }

        //交换颜色的值
        var selfinput_colorobj = cur_trobj.find('div[name="color_div"]');
        var upinput_colorobj = prev_trobj.find('div[name="color_div"]');
        if(selfinput_colorobj.length >0 && upinput_colorobj.length >0){
            var selfpick_color = ld(selfinput).attr('color');
            var upoldpick_color = ld(upinput).attr('color');
            ld(selfinput).attr('color', upoldpick_color);
            selfinput_colorobj.css('background-color', upoldpick_color);
            selfinput_colorobj.attr('color', upoldpick_color);
            ld(upinput).attr('color', selfpick_color);
            upinput_colorobj.css('background-color', selfpick_color);
            upinput_colorobj.attr('color', selfpick_color);
        }
        //上移后修改默认按钮状态
        var popupobj=CrmPopup.getPopupObj("last");
        var set_defaultobj_self = ld("#"+popupobj.divid+" [name=set_default][tag="+selfname+"]");
        var set_defaultobj_up = ld("#"+popupobj.divid+" [name=set_default][tag="+upname+"]");
        var tmp_checked = set_defaultobj_self.prop('checked');
        set_defaultobj_self.prop('checked',set_defaultobj_up.prop('checked'));
        set_defaultobj_up.prop('checked',tmp_checked);
        set_defaultobj_self.attr('tag',upname);
        set_defaultobj_up.attr('tag',selfname);
    }
    //新增
    this.addCombox=function(obj){
        var popupobj=CrmPopup.getPopupObj("last");
        var lasttr = ld('#'+popupobj.divid+' table:first tr:last');
        var lasttr2td = ld(lasttr).children('td:eq(2)');
        //zxm  2021-0618 下拉框颜色值的选择
        var bigtype = ld(obj).attr('data-bigtype');
        var uitype = ld(obj).attr('uitype');
        var style = '';
        if(bigtype!='picklist'){
            style = 'style="display:none;"';
        }
        //wym BUG0074502
        var addtr = '<tr class="ld-edit-combobox ld-category-draggable">' +
            '<td>' +
            '<input class="ld-input-inner" color="" tag="combox" name="new" oldvalue="" value="" type="text"></td>';

        if(this.fieldname=="sales_stage") {
            var tmpaddtr = '<td><input class="ld-input-inner" style="width: 30px;" name="set_winrate" tag="new" value=""> %</td>';
            addtr = addtr+tmpaddtr;
        }
         //wym 240321 XUQIU20240204-09 销售线索可编辑追踪字段
        if(this.fieldname=="status" && this.module=='Leads') {
            var update_module = ['Accounts','Potentials'];
            var tmpaddtr = '<td><div><select MULTIPLE name="set_mapmodule" tag="" class="ld-input-inner select2 select2-offscreen" style="width:100%;">';
            ld.each(update_module,function(index,upmodule){
                if(arrJsPopLabel['module'+upmodule] != '{$'+upmodule+'.'+upmodule+'}'){// 没有翻译表示模块未开启，就没有该选项
                    tmpaddtr += '<option value="'+upmodule+'" >'
                                + arrJsPopLabel['module'+upmodule]
                             + '</option>';
                }
            });
            tmpaddtr += '</select></div></td>';
            addtr = addtr+tmpaddtr;
        }
        addtr=addtr+
            '<td '+style+' align="center">'+
            '<div name="color_div" style="width: 21px;' +
            ' height: 21px;' +
            ' border-radius: 100%;' +
            ' cursor: pointer;' +
            ' border: 1px solid #dbdbdb;background:#3B4859;left:0;top:0;" color="#3B4859" onclick="ComboxPopup.popupobj.chooseColor(this);"></div>'+
            '</td>'+
            '<td style="'+style+'"><input type="checkbox"  onclick="set_picklist_default(this)" name="set_default" id="set_default" tag="new" uitype="'+uitype+'" class="second_switch" ></td>'+
            '<td class="sort_td dragings">' +
                '<div class="displayflex flexcenter">' +
                    '<i class="ld-fonticon ld-fonticon-del" onclick="ComboxPopup.popupobj.delVal(this);" title="'+arrJsPopLabel['DELETE']+'"></i>'+
                    //wym 240109 下拉框-设置-操作列 拖动按钮居中
                    '<a class="ld-category-icon ld-category-drag drag-handle" style="cursor: move;margin-top: 2px;" title="'+arrJsPopLabel['drag']+'"></a>'+
                '</div>' +
            '</td>' +
            '</tr>';
        ld(lasttr).after(addtr);
         //wym 240321 XUQIU20240204-09 销售线索可编辑追踪字段
        ld.each(ld("[name='set_mapmodule']"),function(){
            ld(this).select2({closeOnSelect: false});
        })
        ld(lasttr2td).children("a:eq(1)").show();
		CrmPopup.findHtmlobj(popupobj.divid,'new').focus();
        //31715: PC端：编辑下拉框选项，当选项比较多时新增选项的时候应该自动把滚动条滚动最下面
        ld("#dv_scroll").scrollTop(document.getElementById('dv_scroll').scrollHeight+10);
        ComboxPopup.popupobj.hidesort();
        ComboxPopup.popupobj.center();
    }
    //删除下拉项
    this.delVal=function(obj){
        var objname = ld(obj).parent().parent().prev().prev().prev().find('input').attr('name');
        //edit: xll 2023/05/16 BUG0066506 kfbcrm-销售机会-单据详情-可能性字段-点击删除字段名称-出现的删除下拉框选项界面 应自动勾选刚刚点击删除的字段名称
        //edit: xll 2023/05/19 BUG0066552 删除销售机会中的下拉框未自动勾选
        if(ld(obj).parent().parent().parent().children().first().find('input[tag="combox"]') != undefined ){
            objname = ld(obj).parent().parent().parent().children().first().find('input[tag="combox"]').attr('name');
        }
		var otherurl = '';
		var editpagepopup = CrmPopup.getlastPopupObjByPageType('create_edit_modulepage');
		if ((this.module == 'CashBill' || this.module == 'SendCashBill') && ld("#"+editpagepopup.divid+" [name='selectsource']").length>0) {
			var otherurl = "&selectsourcetype="+ld("#"+editpagepopup.divid+" [name='selectsource']").val();
		}
        if(objname == 'new'){//新增的选项可直接删除
            ld(obj).parent().parent().parent().remove();
            ComboxPopup.popupobj.hidesort();
            ComboxPopup.popupobj.center();
        }
        else{//已存在的选项要先确认替换项再删除
            var that=this;
            ld.ajax({
                url: "index.php?action=PickListAjax&module=PickList&mode=delete&file=ShowPickListSet&modulename="+that.module+"&fieldname="+that.fieldname+"&pickvalue="+objname+otherurl,
                type: 'POST',
                data:'',
                dataType:'json',
                async: true,//
                timeout: 5000,
                error: function(XMLHttpRequest, textStatus, errorThrown) {
                },
                success: function(data){
                    if(data.code==1){
                       	$("status").style.display="none";
                        var DelPopupobj=CrmPopup.load(data.result.title,validateDelete,"","LdPopWidth400px",that.module,[that.fieldname,that.module],data.result.oktext,"",data.result.canceltext);
                        DelPopupobj.show(data.result.content);
                        ComboxPopup.popupobj.center();
                    }
                }
            });
        }
    }
	//删除下拉项 - 删除项不显示在替换下拉框中
    this.replaceval_picklist=function(obj){
        //edit: xll BUG0066552 kfbcrm-销售机会-单据详情-编辑下拉框-点击删除字段-出现的删除下拉框选项界面 如勾选多个字段，替换下拉框里的内容也应隐藏多个
        //var cur_delete_option_text = obj.options[obj.selectedIndex].text;
        var cur_delete_option_text = new Array();
        for(var j=0, k=0; j<obj.length; j++){
			if(obj.options[j].selected == true){
				cur_delete_option_text[k] = obj.options[j].text;
                k++;
			}
		}
		var popupobj=CrmPopup.getPopupObj("last");
		var picklist_obj =CrmPopup.findHtmlobj(popupobj.divid,'replaceList');
		picklist_obj.val('');
		for(var i = 0; i < picklist_obj.get(0).options.length; i++){
			var tmp = picklist_obj.get(0).options[i].value;
			if(cur_delete_option_text.includes(tmp)){
				picklist_obj.get(0).options[i].hide();
			}else{
				picklist_obj.get(0).options[i].show();
			}
		}
    }

    //选择颜色 zxm  2021-0618 下拉框颜色值的选择
    this.chooseColor = function(obj){
        var pick_color = ld(obj).attr('color');
        var css_type = pick_color==''||pick_color==undefined?'#F3F3FC':pick_color;
        var crmPopupobj=CrmPopup.load("","","","LdPopWidth400px",'Settings',"","","","");
        crmPopupobj.prevshow();
        var url='index.php?module=PickList&action=PickListAjax&file=PickListActions&mode=gethtml';
        var dataurl='selectedcolor='+css_type;
        ldAjaxNoProgress(url,dataurl,function (data){
            if (data.code == 1){
                crmPopupobj.setParams(data.result.title,'',"","LdPopWidth400px",'Settings',"",'',"",'');
                crmPopupobj.show(data.result.content);
                var divid=crmPopupobj.divid;
                //加载自定义
                that.getColPick(obj,crmPopupobj);
                //页签点击事件
                ld("#"+divid+" #changetab").find('[name=tag]').unbind('click').bind('click',function () {
                    //隐藏之前选中的页签
                    var selected=ld("#"+divid+" #changetab").find('.ld-change-tab-active');
                    ld('#'+divid+' #'+selected.attr('tag')).hide();
                    selected.removeClass('ld-change-tab-active');
                    //显示选中页签
                    var tag=ld(this).attr('tag');
                    ld(this).addClass('ld-change-tab-active');
                    ld('#'+divid+' #'+tag).show();
                });
                //浅色亮色色块点击事件
                var color=ld('#'+divid+' #preset').find('[name=presetcolor_li]');
                ld(color).unbind('click').bind('click',function () {
                    var selectedcolor=ld(this).find('[name=presetcolor]').attr('color');
                    // var rgba=that.getColorRgba(selectedcolor);
                    crmPopupobj.CancelEvent();
                    var trobj = ld(obj).parent().parent();
                    trobj.find('input[name="color_input"]').val(selectedcolor);
                    trobj.find('input[tag="combox"]').attr('color',selectedcolor);//给input赋值颜色属性
                    // trobj.find('div[name="color_div"]').css('background',rgba);
                    trobj.find('div[name="color_div"]').css('background',selectedcolor);
                    trobj.find('div[name="color_div"]').attr('color',selectedcolor);
                    // trobj.find('div[name="color_div"]').css('border','1px solid '+selectedcolor);
                })
            }
        });
    }
    this.getColorRgba=function (color,cpacity=''){
        if (empty(color)){
            return '';
        }
        color=color.replace('#','');
        var color_arr=color.split('');
        if (color_arr.length == 3){
            var red = parseInt(color_arr[0]+color_arr[0], 16);
            var green = parseInt(color_arr[1]+color_arr[1], 16);
            var blue = parseInt(color_arr[2]+color_arr[2], 16);

        }else if (color_arr.length == 6){
            var red = parseInt(color_arr[0]+color_arr[1], 16);
            var green = parseInt(color_arr[2]+color_arr[3], 16);
            var blue = parseInt(color_arr[4]+color_arr[5], 16);
        }
        cpacity=(cpacity == '')?0.1:cpacity;
        if (cpacity<0 || cpacity >=1){
            var rgba='rgba(' + red + ',' + green + ',' + blue + ')';
        }else {
            var rgba='rgba(' + red + ',' + green + ',' + blue + ',' + cpacity +')';
        }
        return rgba;

    }
    //恢复默认颜色  zxm  2021-0618 下拉框颜色值的选择
    this.recoveryDefaultColor = function(obj){
        var crmPopupobj = CrmPopup.getPopupObj("last");
        var divid = crmPopupobj.divid;
        var defaultBack = "#3B4859";
        ld('#'+divid+' [tag="combox"]').each(function(){
            ld(this).attr('color','#3B4859');
        });
        ld('#'+divid+' [name="color_div"]').each(function(){
            ld(this).css('background-color',defaultBack);
            ld(this).attr('color','');
        });
    }
    this.getColPick=function (obj,popupobj) {
        var colpick_num = 1;
        var pick_color = ld(obj).attr('color');
        var css_type = pick_color==''||pick_color==undefined?'#F3F3FC':pick_color;
        var trobj = ld(obj).parent().parent();
        getJsScript('include/js/colpick/colpick.js',function(){
            getJsScript('include/js/colpick/plugin.js',function(){
                var divid = popupobj.divid;
                CrmPopup.findHtmlobj(divid,'picker').colpick({
                    color:css_type,
                    flat:true,
                    layout:'RGB',
                    submitText:'确认',
                    onSubmit:function(hsb,hex,rgb,el){//ok之后的确认事件
                        var _color = '#'+hex;
                        // var rgba=that.getColorRgba(_color);
                        trobj.find('input[name="color_input"]').val(_color);
                        trobj.find('input[tag="combox"]').attr('color',_color);//给input赋值颜色属性
                        // trobj.find('div[name="color_div"]').css('background',rgba);
                        trobj.find('div[name="color_div"]').css('background',_color);
                        trobj.find('div[name="color_div"]').attr('color',_color);
                        // trobj.find('div[name="color_div"]').css('border','1px solid '+_color);
                        popupobj.CancelEvent();
                    }

                });
                popupobj.center();
                // var windowWidth = document.documentElement.clientWidth;
                // var windowHeight = document.documentElement.clientHeight;
                // if(colpick_num == 1)
                //     var popupHeight = ld('#'+divid).height()-126;
                // else{
                //     var popupHeight = ld('#'+divid).height();
                // }
                // colpick_num++;
                // var popupWidth = ld('#'+divid).width();
                // ld('#'+divid).css({
                //     "position": "fixed",
                //     "top": (windowHeight-popupHeight)/2,   //+ld(document).scrollTop()明细界面的相关信息，滚动条到最下面，则弹出层显示错误
                //     "left": (windowWidth-popupWidth)/2
                // });
            });
        });
    }
}
function getFolderCombox(){
    
    ld.ajax({
        url: 'index.php?module=Documents&action=DocumentsAjax&file=showfolders',
        type: 'POST',
        data:'',
        dataType:'json',
        async: true,//
        timeout: 20000,
        error: function(XMLHttpRequest, textStatus, errorThrown) {
        },
        success: function(data)
        {
            if(data.code==1)
            {
               	$("status").style.display="none";
                
                var ComboxPopupobj=ComboxPopup.load(data.result.title,FolderComboxSave,"","LdPopWidth350px","Documents",["Documents","folderid"],data.result.oktext,"",data.result.canceltext);
                ComboxPopupobj.refreshpage='yes';
                ComboxPopupobj.show(data.result.content);
                ComboxPopupobj.hidesort();     
                //31715: PC端：编辑下拉框选项，当选项比较多时新增下拉框选项应该自动把滚动条滚动最下面
                  //  ld("#dv_scroll").scrollTop(document.getElementById('dv_scroll').scrollHeight);   
               
                 
                       
            }
        }
    });
}

//保存
function FolderComboxSave(module,fieldname){
    var popupobj=CrmPopup.getPopupObj("last");
    var comboxarr = [];
    var emptycheck = true;
    ld("#"+popupobj.divid+" input[tag='combox']").each(function(){
        var comboxname = ld(this).attr('name');
        var comboxval = ld(this).val();
        var comboxoldval = ld(this).attr('oldvalue');

        if(empty(comboxval)){
            emptycheck = false;
        }
        var comboxtext = {'type':''+comboxname+'','oldval':''+comboxoldval+'','value':''+comboxval+''};
        comboxarr.push(comboxtext);
    });
    if(!emptycheck){
        var confirm_str = arrJsPopLabel['DROPDOWNBOXOPTIONCANOTEMPTY'];
        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
        return false;
    }
  
    var comboxjson = JSON.stringify(comboxarr);
    var selectvalue = ld(":input[name='"+fieldname+"']").val();
    ld.ajax({
        url: 'index.php?module=Documents&action=DocumentsAjax&file=SaveFolders',
        type: 'POST',
        data:'fld_module='+module+'&fieldname='+fieldname+'&comboxjson='+comboxjson+'&mode=save',
        dataType:'json',
        async: true,//
        timeout: 20000,
        error: function(XMLHttpRequest, textStatus, errorThrown) {
        },
        success: function(data)
        {
            if(data.code==1)
            {
                coverComboxContent(data.result,fieldname);
                popupobj.CancelEvent();
            }
            else
            {
                var confirm_str = data.msg+arrJsPopLabel['ALREADYEXISTSREENTRY'];
                RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
            }
        }
    });
}
FolderComboxSave.funname="FolderComboxSave";

function getCombox(module,fieldname)
{
    var popupobj=CrmPopup.getPopupObj("last");

     if(popupobj.picklistobjarray!=undefined&&popupobj.picklistobjarray[fieldname]!=undefined&&popupobj.picklistobjarray[fieldname].parentdependfieldname!=""&&ld("#"+popupobj.divid+" [name="+popupobj.picklistobjarray[fieldname].parentdependfieldname+"]").val()!="")
     {
            DepencyEditFirst(module,popupobj.picklistobjarray[fieldname].parentdependfieldname,fieldname,"","");
     }
     else
     {
         var url='index.php?module=PickList&action=PickListAjax&file=ShowPickListSet&mode=combox&modulename='+module+'&fieldname='+fieldname;
         //ZXM 预算单  需要知道是哪种指标
         if(module=='ExpenseBudget'&&fieldname=='budget_indicators'){
             url='index.php?module='+module+'&action='+module+'Ajax&file=budgetIndicatorsListSet&modulename='+module+'&fieldname='+fieldname;
             var expensebudget_type = ld("#"+popupobj.divid+" [name='expensebudget_type']").val();
             url+='&expensebudget_type='+expensebudget_type;
         }
         if(popupobj.picklistobjarray!=undefined&&popupobj.picklistobjarray[fieldname] != undefined && popupobj.picklistobjarray[fieldname].parentdependfieldname!="")
         {
             var parentdependfieldname=popupobj.picklistobjarray[fieldname].parentdependfieldname;
             var parentfieldvalue=ld("#"+popupobj.divid+" [name="+parentdependfieldname+"]").val();
             url+="&parentdependfieldname="+parentdependfieldname+"&parentfieldvalue="+parentfieldvalue;
         }
		 var otherurl = '';
		 if ((module == 'CashBill' || module == 'SendCashBill') && ld("#"+popupobj.divid+" [name='selectsource']").length>0) {
			var otherurl = "&selectsourcetype="+ld("#"+popupobj.divid+" [name='selectsource']").val();
		 }
		 url+=otherurl
         if(module=='ExpenseBudget'&&fieldname=='budget_indicators') {
             ComboxPopup.showLayer(url, module, fieldname, ExpenseBudgetObj.ComboxSave);
         }else{
             ComboxPopup.showLayer(url, module, fieldname, ComboxSave);
         }
     }
}

/*
下拉框编辑保存是否要替换历史数据的弹出层
callbackfun:点击确定后的回调函数，或者没有下拉框改变的回调函数
*/
ComboxPopup.showReplaceHistoryDataLayer=function(changedcombox,callbackfun)
{
    var lastprevpopupobj=CrmPopup.getPopupObj("last");
    
    if(changedcombox==undefined||changedcombox.length<=0)
    {
        callbackfun();
        return false;
    }
    if(lastprevpopupobj.module=='Settings')
    {
        //控制面板编辑下拉框
        var module=lastprevpopupobj.selectmodule;
    }
    else
    {
        //模块中编辑下拉框选项
        var module=lastprevpopupobj.module;
    }
    var fieldname=lastprevpopupobj.editfieldname;
    var url="index.php?module=PickList&action=PickListAjax&file=showChangedComboxLayer";
     var Popupobj=CrmPopup.load("",ComboxPopup.getNeedChangedDataByComobox,"","LdPopWidth350px",module,"","","","");
    ld.ajax({
        url: url,
        type: 'POST',
        data: "fieldname="+fieldname+"&moduleName="+module+"&changedcombox="+JSON.stringify(changedcombox),
        dataType:'json',
        async: true,//
        timeout: 5000,
        error: function(XMLHttpRequest, textStatus, errorThrown) {
        },
        success: function(data)
        {
            if(data.code==1)
            {
               	$("status").style.display="none";
                 Popupobj.createScrollDiv();//创建滚动条  
                 Popupobj.setHeadTitle(data.result.title);
                 Popupobj.setCancelText(data.result.canceltext);
                 Popupobj.setOkText(data.result.oktext); 	
                 Popupobj.show(data.result.content);	   
                 Popupobj.setScrollDivMaxHeight(); 
                 Popupobj.Okfunction=callbackfun;//点击确定后调用的函数   
                 ld("#"+Popupobj.divid+" [name=chkall]").bind("click",function(){
                   
                    if(ld(this).prop("checked")==true)
                         ld("#"+Popupobj.divid+" [name=chk_operate]").prop("checked",true);
                    else  
                        ld("#"+Popupobj.divid+" [name=chk_operate]").prop("checked",false);  
                 });
                 ld("#"+Popupobj.divid+" [name=chk_operate]").bind("click",function(){
                      if(!ld(this).prop("checked"))
                      {
                        ld("#"+Popupobj.divid+" [name=chkall]").prop("checked",false);
                      }
                 });
            }
        }
    });
}
/*
获取需要修改历史数据的下拉框
*/
ComboxPopup.getNeedChangedDataByComobox=function()
{

    var popupobj=CrmPopup.getPopupObj("last");
    var chks=ld("#"+popupobj.divid+" [name=chk_operate]");
    var needchangedhistorycombox=[];
    ld.each(chks,function(){
        var newvalue=ld(this).attr('newvalue');
        var oldvalue=ld(this).attr('oldvalue');
        if(ld(this).prop("checked"))
                needchangedhistorycombox.push({"newvalue":newvalue,"oldvalue":oldvalue});
    });
    var Okfunction=popupobj.Okfunction;
    popupobj.CancelEvent();//关闭改变历史数据的弹出框
    popupobj=CrmPopup.getPopupObj("last");//下拉框编辑的弹出层
    popupobj.changedcombox=needchangedhistorycombox;
   
    //保存下拉框数据并替换历史数据
    Okfunction();//有两个保存函数（savePickList,ComboxSave)
}
ComboxPopup.getNeedChangedDataByComobox.funname="ComboxPopup.getNeedChangedDataByComobox";

ComboxPopup.showLayer=function(url,module,fieldname,okfunctionname){
    var ComboxPopupobj=ComboxPopup.load('','',"",'LdPopWidth600px',module,[module,fieldname],'',"",'');
    //console.log(data.result.title+'------------'+ComboxSave+'------------'+""+'------------'+"LdPopWidth350px"+'------------'+module+'------------'+[module,fieldname]+'------------'+data.result.oktext+'------------'+""+'------------'+data.result.canceltext);
    ComboxPopupobj.refreshpage='yes';
    ComboxPopupobj.prevshow();
     ld.ajax({
        url: url,
        type: 'POST',
        data:'',
        dataType:'json',
        async: true,//
        timeout: 10000,
        error: function(XMLHttpRequest, textStatus, errorThrown) {
        },
        success: function(data)
        {
            if(data.code==1)
            {
                ComboxPopupobj.setParams(data.result.title,okfunctionname,"",'LdPopWidth600px',module,[module,fieldname],data.result.oktext,"",data.result.canceltext);
               	//$("status").style.display="none";
                ComboxPopupobj.show(data.result.content);

                // 需要去掉的给高度
                ComboxPopupobj.reduceBodyHeight = 42;
                // 设置内容最大高度
                ComboxPopupobj.setPopBodyMaxHeight("#dv_scroll");

                //BUG0072639 20230928 txy kfbcrm-下拉框字段设置界面优化，改为查询分类弹出层的样式 绑定拖拽事件
                if(ld('#'+ComboxPopupobj.divid+' .ld-pop-container table').length > 0) {
                    Sortable.create(ld('#'+ComboxPopupobj.divid+" .ld-pop-container table tbody").get(0), {
                        group: 'editcombobox',
                        draggable:".ld-category-draggable",
                        handle:".drag-handle",
                        animation: 150,
                        sort: true,
                    });
                }
                ComboxPopupobj.hidesort();
                ComboxPopupobj.editfieldname=fieldname;//修改的下拉框字段
                 //wym 240321 XUQIU20240204-09 销售线索可编辑追踪字段
                ld.each(ld("[name='set_mapmodule']").not(":hidden"),function(){
                    ld(this).select2({closeOnSelect: false});
                });
            }
        }
    });
}

ComboxPopup.type="combox";
ComboxPopup.popupobj="";

ComboxPopup.load=function(headtitle,Okfun,Cancelfun,cssWidth,module,OkfunParamObj,OkText,CancelfunParamObj,CancelText)
{
     ComboxPopup.prototype=new CrmPopup();  
     ComboxPopup.prototype.constructor=ComboxPopup;  

     
     ComboxPopup.prototype.type=ComboxPopup.type;
     ComboxPopup.prototype.module=OkfunParamObj[0];
     ComboxPopup.prototype.fieldname=OkfunParamObj[1];
     
     var  ComboxPopupobj=new ComboxPopup();
     ComboxPopupobj.setParams(headtitle,Okfun,Cancelfun,cssWidth,module,OkfunParamObj,OkText,CancelfunParamObj,CancelText);
     ComboxPopup.popupobj=ComboxPopupobj;
     return ComboxPopupobj;
}


//保存
function ComboxSave(module,fieldname){
    var popupobj=CrmPopup.getPopupObj("last");
    var comboxarr = [];
    var emptycheck = true;
    var changedcombox=[];
    
   var selectvalue = ld("#"+popupobj.divid+" [name='"+fieldname+"']").val();
    ld("#"+popupobj.divid+" input[tag='combox']").each(function(){
        var comboxname = ld(this).attr('name');
        var comboxval = encodeURIComponent(ld.trim(ld(this).val()));
        var comboxoldval = encodeURIComponent(ld(this).attr('oldvalue'));
        //获取默认值设置
        var set_defaultobj = ld("#"+popupobj.divid+" [name=set_default][tag="+comboxname+"]");
        //获取赢率
        var set_winrateobj = ld("#"+popupobj.divid+" [name=set_winrate][tag="+comboxname+"]");
        var winrate=set_winrateobj.val();
        var mapmodule="";
        if(fieldname=="status" && module=='Leads'){
            //wym 240321 XUQIU20240204-09 销售线索可编辑追踪字段 隐藏的多选框没有生成select2 直接取值
            if(ld("#"+popupobj.divid+" [name=set_mapmodule][tag="+comboxname+"]").css('display')=='none'){
                var mapmodule = ld("#"+popupobj.divid+" [name=set_mapmodule][tag="+comboxname+"]").find("option:selected").val();
            }else{
                var picklistvalue=ld("#"+popupobj.divid+" [name=set_mapmodule][tag="+comboxname+"]").select2('data');
                if(picklistvalue!=undefined){
                    var fldPickListvalues=[];
                    ld.each(ld("#"+popupobj.divid+" [name=set_mapmodule][tag="+comboxname+"]").select2('data'),function(index,info){
                        var value=info.id;
                        fldPickListvalues.push(value);
                    });
                    var mapmodule = fldPickListvalues.join(":");
                } else
                    var mapmodule="";
            }
        }
        if(set_defaultobj.prop('checked')){
            var set_default = 'yes';
        }else{
            var set_default = 'no';
        }
        //选中的颜色 zxm  2021-0617
        var pick_color = ld(this).attr('color');
        if(empty(comboxval)){
            emptycheck = false;
        }
        var comboxtext = {'type':''+comboxname+'','oldval':''+comboxoldval+'','value':''+comboxval+'','pick_color':''+pick_color+'','set_default':set_default,'winrate':winrate,'mapmodule':mapmodule};
        comboxarr.push(comboxtext);
        if(comboxoldval!=comboxval&&comboxname!='new')
        {

            changedcombox.push(comboxtext);
        }
    });
    if(!emptycheck){
        var confirm_str = arrJsPopLabel['DROPDOWNBOXOPTIONCANOTEMPTY'];
        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
        return false;
    }
    popupobj.comboxarr=comboxarr;
    popupobj.changedcombox=changedcombox;
    popupobj.fieldname=fieldname;
    
    if(changedcombox.length<=0)
    {
        //没有改变直接保存，不需要弹出询问框
        afterOkComboxSave();
    }
    else
    {
         ld("#"+popupobj.divid+" .D_pbtnok").attr("disabled",false);
        ComboxPopup.showReplaceHistoryDataLayer(changedcombox,afterOkComboxSave);
    }
}
ComboxSave.funname="ComboxSave";
ComboxSave.isoksave='no';
function afterOkComboxSave(){
    if(ComboxSave.isoksave=='yes')
        return ;
    ComboxSave.isoksave='yes';
    var firstpopupobj=CrmPopup.getPopupObj('first');
    var  prevpopupobj=CrmPopup.getPopupObj("lastprev");
    var popupobj=CrmPopup.getPopupObj("last");
    var comboxarr=popupobj.comboxarr;
    var changedcombox=popupobj.changedcombox;
    var fieldname=popupobj.fieldname;

    var module=popupobj.module;
    var comboxjson = JSON.stringify(comboxarr);
    var selectvalue = ld(":input[name='"+fieldname+"']").val();
    if(firstpopupobj.module=='Settings' || CrmPopup.getPopupObj(1).module=='Settings' || (firstpopupobj.module == 'Campaigns' && fieldname == 'campaignaccountrelstatus')){
        var tmp_selectvalue = comboxarr.filter(item => item.set_default == "yes").map(item => item.type);//BUG0071704 xxy 2023-8-29 后台设置-客户管理-页面设置-重要级别字段编辑页面，默认值右边齿轮设置功能不生效
        var selectvalue = [];
        ld.each(tmp_selectvalue, function (index, value) {// 2024-6-24 xxy 字段类型为多选框时，设置默认值不成功
            selectvalue[index] = ld(":input[name='"+value.toString()+"']").val();
        });
        selectvalue = selectvalue.toString();
    }

    var url='index.php?module=PickList&action=PickListAjax&file=PickListActions&mode=save';
    if(changedcombox.length>0)
   {
        url+="&changedcombox="+encodeURIComponent(JSON.stringify(changedcombox));
        
   }
    var otherurl = '';
    if ((module == 'CashBill' || module == 'SendCashBill') && ld("#"+prevpopupobj.divid+" [name='selectsource']").length>0) {
        var otherurl = "&selectsourcetype="+ld("#"+prevpopupobj.divid+" [name='selectsource']").val();
    }

    ld.ajax({
        url:url,
        type: 'POST',
        data:'fld_module='+module+'&fieldname='+fieldname+'&comboxjson='+encodeURIComponent(comboxjson)+'&selectvalue='+selectvalue+otherurl,
        dataType:'json',
        async: true,//
        timeout: 700000,
        error: function(XMLHttpRequest, textStatus, errorThrown) {
        },
        success: function(data)
        {
            ComboxSave.isoksave='no';
            if(data.code==1)
            {
                coverComboxContent(data.result,fieldname);
                popupobj.CancelEvent();
                popupobj=CrmPopup.getPopupObj("last");
                var isdetailfieldname='no';
				//页面设置
                var selectedtext='';
                var selectedcolor='';
                if(data.result.selecttext){
                    ld.each(data.result.selecttext, function (index, info) {
                        if (info[2] == 'selected') {
                            selectedtext = info[1];
                            selectedcolor = info[3];//读取所修改字段的颜色值
                            return false;
                        }
                    });
                }

				if(firstpopupobj.module=='Settings' || CrmPopup.getPopupObj(1).module=='Settings' || (firstpopupobj.module == 'Campaigns' && fieldname == 'campaignaccountrelstatus'))
                {
					//市场活动，相关信息客户列表，状态设置
                    if(firstpopupobj.module == 'Campaigns' && fieldname == 'campaignaccountrelstatus'){
						popupobj.htmlselectid = 'campaignaccountrelstatus';
						ld("#"+popupobj.divid+" [name='cmb_ul_campaignaccountrelstatus']").empty();
						ld.each(data.result.selecttext,function(index,info){
							ld("#"+popupobj.divid+" [name='cmb_ul_campaignaccountrelstatus']").append('<li style="" class="active-result" name="dv_chzn_'+index+'_campaignaccountrelstatus" onclick="cmb_liclick(\'\',\'campaignaccountrelstatus\')" onmouseover="cmb_limouseover(event,\'campaignaccountrelstatus\')">'+info[1]+'</li>');
						});
					}
                    ld("#"+popupobj.htmlselectid).empty();
                    //zkt 20230609 BUG0066771 kfbcrm，页面设置，下拉框字段编辑界面，设置默认值，点击设置图标，点击保存，再次点击设置图标，保存--默认值变成“null” 
                    ld.each(data.result.selecttext, function (index, info) {
                        ld("#" + popupobj.htmlselectid).append("<option value='" + info[0] + "' " + info[2] + " >" + info[1] + "</option>");
                        if (info[2] == 'selected') {
                            selectedtext = info[1];
                            selectedcolor = info[3];//读取所修改字段的颜色值
                        }
                    });
                   if(prevpopupobj.uitype==15)
                   {
                    // //edit:can 2020-09-04  42590: （61mis.com/kfbcrm）徐燕男客户问题，系统设置>客户模块页面设置界面：编辑“客户状态”字段，修改“默认值”字段属性（例如把“潜在客户”修改为“111”），保存后默认值显示“null”(需要补丁）
                        var name= ld("#"+popupobj.htmlselectid).attr("name");
                       
                        ld("#"+popupobj.divid+" [name=cmb_span_optiontext_"+name+"]").val(selectedtext);
                        ld("#"+popupobj.divid+" [name=cmb_span_optiontext_"+name+"]").css('color',selectedcolor);//BUG0065318 徐心玥 2023-4-26 修改字段颜色，保存后，下拉框选中的字段颜色实时更新
                        //zkt 20220511 51674（https://81mis.com/kfbtest/index.php）系统设置》页面设置》客户，编辑所属行业字段，新增下拉框选项，新增的选项在设置默认值时找不到，关掉编辑字段属性界面再打开才会显示
                        if(ld("#"+popupobj.divid).find(' [name=dv_chzn_'+fieldname+']')!=undefined)
                        {
                            var selecteddivobj=ld("#"+popupobj.divid).find(' [name=dv_chzn_'+fieldname+']');
                            var selectedulobj=ld(selecteddivobj).find(' [id=cmb_ul_'+fieldname+']');
                            ld(selectedulobj).empty();
                            var tmpfieldid=prevpopupobj.fieldid;
                            ld.each(data.result.selecttext,function(index,info){
                           
                                //zkt 20220527 52271	点击齿轮新建一个下拉框之后，就会默认选择第一个选项：项目准备，选择其它的都没用，需要关掉这个编辑状态的窗口重新打开才能选择
                                ld(selectedulobj).append('<li style="color:'+info[3]+';" class="active-result" name="dv_chzn_'+index+'_'+fieldname+'"  onclick="cmb_liclick(\''+info[1]+'\',\''+fieldname+'\',\'dv_cmb_'+fieldname+'\');cmb_defaultvalue_checked(this,\'select\',\''+tmpfieldid+'\',\''+fieldname+'\');" onmouseover="cmb_limouseover(event,\''+fieldname+'\',\'dv_cmb_'+fieldname+'\')" >'+info[1]+'</li>');
                                
                                
                            });
                            ld(selectedulobj).append("<li style='' class='' name='li_chzn_"+fieldname+"' >"+arrJsPopLabel['NOMATCHINGITEMS']+"</li>");
                        }
                        
                   }
                   
                   else if(prevpopupobj.uitype==33)
                    {
                       
                        var selectext=ld("#"+popupobj.htmlselectid).select2('data');
                       
                        var tmparr=new Array();
                        for(var i=0;i<selectext.length;i++)
                        {
                            tmparr.push(selectext[i].id);
                            
                        }
                       
                        var tmpselecttext=tmparr.join('##');
                        
                         for(var i=0;i<changedcombox.length;i++)
                         {
                            var comboxoldval=changedcombox[i].oldvalue;
                            var comboxval=changedcombox[i].newvalue;
                            tmpselecttext=tmpselecttext.replace(comboxoldval,comboxval);
                            
                         }
                        
                         selectext=tmpselecttext.split('##');
                         
                       
                         ld("#"+popupobj.htmlselectid).val(selectext).trigger("change");;
                    }
                    return false;
                }else{
                    //wym BUG0073484 批量编辑popobj没有定义getDetailTableObj
                    if (typeof popupobj.getDetailTableObj === 'function') {
                        if(popupobj.getDetailTableObj()!=undefined && popupobj.getDetailTableObj() != 'undefined' && popupobj.getDetailTableObj().length>=1){
                            var rowobjs=popupobj.getTrObjsByDelType("no");
                            //edit:can 2020-12-23 43890: （61mis.com/kfbcrm）销售管理-合同订单（需要补丁）；合同订单的产品分录中，点击下拉框字段右侧的设置图标，新增或删除下拉框选项值，保存后没有生效
                            //@王can  请优先安排修改下
                            //明细下拉框
                            ld.each(rowobjs,function(){

                                if( ld(this).find(" [detailcolumnname="+fieldname+']').attr("fieldtype") == 'select'){
                                    isdetailfieldname='yes';
                                    var before_value = ld(this).find(" [detailcolumnname="+fieldname+']').val();
                                    var new_array={};
                                    var tmprowobj=ld(this);
                                    var newvalue='';
                                    var picklist_options = [];
                                    var picklist_colors = {};
                                    ld.each(data.result.changedcombox, function (key, opts) {

                                        if (opts.oldval == before_value && before_value != null) {

                                            ld(tmprowobj).find(" [detailcolumnname=" + fieldname + ']').val(opts.value);
                                            newvalue = opts.value;
                                            ld(tmprowobj).find(" [name=cmb_span_optiontext_" + fieldname + ']').val(opts.value);
                                        }
                                        new_array[opts.value] = opts.value;
                                        picklist_options[key] = opts.value;
                                        picklist_colors[opts.value] = opts.pick_color;

                                    })

                                    if(popupobj.detailfieldmodule=='Products' && popupobj.detailpicklist[fieldname]){
                                        // BUG20240506-59 xxy 2024-5-24 产品分录下拉框字段，点齿轮编辑，新增一个选项，保存后点下拉框没有新增的选项 
                                        picklist_options.unshift('');
                                        popupobj.detailpicklist[fieldname] = new_array;
                                        popupobj.detailpicklistseq[fieldname] = picklist_options;
                                        popupobj.detailpicklistColors[fieldname] = picklist_colors;
                                        
                                    }else{
                                        //edit:can 2021-01-12 0044225: （https://61mis.com/kfbcrm [^] ）（云泰五金）OA表单-费用报销单-单据分录中的下拉框字段（费用类别）在添加了下拉框选项保存之后，不会立即显示新增的选项，必须要刷新一次页面。
                                        ld(this).find(" [detailcolumnname="+fieldname+']').empty();
                                        var optionhtml='';
                                        optionhtml+="<option></option>";
                                        ld.each(picklist_options,function(tmpkey,tmpvalue){
                                            optionhtml+="<option pickcolor='"+picklist_colors[tmpvalue]+"' value='"+tmpvalue+"'>"+tmpvalue+"</option>";
                                        });
                                        ld(this).find(" [detailcolumnname="+fieldname+']').append(optionhtml);
                                        if(before_value != null){
                                            ld(this).find(" [detailcolumnname="+fieldname+']').val(newvalue);
                                        }
                                    }

                                    ld(this).find(" [name=cmb_ul_"+fieldname+']').find("[tag=livalue]").remove();
                                    popupobj.SetDetailFieldControl(ld(this).attr("rowindex"));

                                    var cur_input = ld(this).find(" [name=cmb_span_optiontext_"+fieldname+"]");
                                    cur_input.css('color',picklist_colors[cur_input.val()]);
                                }

                            })
                        }
                    }
					if(ld("#"+popupobj.divid).find(" [name=cmb_span_optiontext_"+fieldname+"]").length>0){
						for(var i=0;i<changedcombox.length;i++)
						{
							//修改编辑界面，新增界面下拉框文本框的值
								var comboxoldval=changedcombox[i].oldvalue;
								var comboxval=changedcombox[i].newvalue;
							  
							 if(trim(ld("#"+popupobj.divid+" [name=cmb_span_optiontext_"+fieldname+"]").val())==comboxoldval)
							{
								ld("#"+popupobj.divid+" [name='"+fieldname+"']").val(comboxval);
								ld("#"+popupobj.divid+" [name=cmb_span_optiontext_"+fieldname+"]").val(comboxval);
								break;
							}
						}
                    }
				}
                if(isdetailfieldname=='yes')
                {
                    //修改的明细字段的下拉框
                    return ;
                }
               //填充账户字段的下拉框选项
                if(prevpopupobj.fieldname_fields[fieldname]){
                    if(prevpopupobj.fieldname_fields[fieldname].uitype==251 ||prevpopupobj.fieldname_fields[fieldname].uitype==252)
                    {
                        var cls_resetComboxHtmlobj=new cls_resetComboxHtml(fieldname);
                        //var select_text= ld("#"+prevpopupobj.divid+" input[name='cmb_span_optiontext_bankaccountsetid']");
                        //console.log(select_text);
                        ld("#"+prevpopupobj.divid+" [name="+fieldname+"]").empty();
                        cls_resetComboxHtmlobj.setPopupObj(prevpopupobj);
                        //wym 231204 BUG0073303 kfbcrm-佣金单-新建-对“账户”字段的下拉框值进行设置，保存后，”账户“字段文本框变短
                        cls_resetComboxHtmlobj.setComboxObjHtmlByWidth(280);


                        var option='';
                        for(i=0;i<data.result.changedcombox.length;i++){
                            option += "<option value='"+data.result.changedcombox[i]['bankaccountsetid']+"' bank_curid='1' >"+data.result.changedcombox[i]['value']+"</option>";
                        }

                        if(ld("#"+prevpopupobj.divid+" select[name="+fieldname+"]").length>0){
                            ld("#"+prevpopupobj.divid+" select[name="+fieldname+"]").html(option);
                        }


                        //ld("#"+prevpopupobj.divid+" input[name=cmb_span_optiontext_bankaccountsetid]").val(select_text);
                        return false;
                    }
                }
                if(popupobj.picklistobjarray[fieldname]){
                    popupobj.picklistobjarray[fieldname].picklistcontentarray=data.result.selecttext;
                }

                if(popupobj.picklistcontent != null){
                    for (var k = 0; k < popupobj.picklistcontent.length; k++) {
                        var tmpfieldname=popupobj.picklistcontent[k].fieldname;
                        if(tmpfieldname==fieldname)
                        {

                            // edit:can 2021-01-14 44173: （本地php72，8.3.6）客户管理-客户（火狐浏览器）；新增客户时，修改“客户类型”字段的下拉选项值，下拉选项和布局规则中设置的触发选项没有立即变更
                            popupobj.picklistcontent[k].optionvalue=data.result.selecttext;
                            break;
                        }
                    }
                }
                if(popupobj.picklistobjarray[fieldname]) {
                    for (var i = 0; i < popupobj.picklistobjarray[fieldname].childdependfieldname.length; i++) {
                        var childfieldname = popupobj.picklistobjarray[fieldname].childdependfieldname[i];
                        if (popupobj.picklistobjarray[childfieldname] != undefined)
                            popupobj.picklistobjarray[childfieldname].picklistdepency = null;

                    }
                    if (popupobj.picklistobjarray[fieldname].parentdependfieldname != "") {
                        //重新给级联字段赋值(函数)
                        popupobj.picklistobjarray[fieldname].getpicklistDepencyByParentFieldname();
                    }
                    //edit:can 2021-01-1 44173: （本地php72，8.3.6）客户管理-客户（火狐浏览器）；新增客户时，修改“客户类型”字段的下拉选项值，下拉选项和布局规则中设置的触发选项没有立即变更
                    if(popupobj.fieldruleobj!=undefined && popupobj.fieldruleobj!= 'undefined')
                        popupobj.fieldruleobj.CheckReLoadPopup();
                }

                if(prevpopupobj.fieldname_fields[fieldname]){
                    //edit:duan date:2024/10/29 reason:用户模块的职位级别字段处理,修改下拉框后，对应选项要同步修改
                    if(prevpopupobj.fieldname_fields[fieldname].uitype==34){
                        changed_related_picklist(fieldname,data.result.changedcombox)
                    }
                }

            }
            else
            {
               
                var confirm_str = data.msg+arrJsPopLabel['ALREADYEXISTSREENTRY'];
                RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
            }
        }
    });
}
//删除弹出层的行
function delComboxTr(valarr){
    var popupobj = CrmPopup.getPopupObj("last");
    for(var i=0;i<valarr.length;i++){
        var deltr = ld("#"+popupobj.divid+" input[name='"+valarr[i]+"']");
        ld(deltr).parent().parent().remove();
        ComboxPopup.popupobj.hidesort();
    }
}
//覆盖下拉框内容
function coverComboxContent(content,fieldname){
    if(content.comboxtype=='onepick'){//下拉框
        
       // ld(":input[name='"+fieldname+"']").html(content.optiontext);
      //  ld("ul[name='cmb_ul_"+fieldname+"']").html(content.selecttext);
      //  var selectval = ld(":input[name='"+fieldname+"']").val();
      //  cmb_liclick(selectval,fieldname);
    }else if(content.comboxtype=='multipick'){//多选框
        var divObj = ld('div[id=s2id_'+fieldname+'] ul li');
        if(divObj.length > 0)
            ld('div[id=s2id_'+fieldname+'] ul li').each(function(){
                if(ld(this).attr('class') == 'select2-search-choice'){
                    ld(this).remove();
                }
            });
        ld(":input[name='"+fieldname+"[]']").html(content.optiontext);

    }
    var spanObj = ld("span[name='cmb_span_optiontext_"+fieldname+"']");
    if(spanObj.length > 0)
        spanObj.val(ld(":input[name='"+fieldname+"']").val());
}

//判断下拉框还是多选框，使得下拉框单选，多选框多选
function set_picklist_default(obj){
    var popupobj=CrmPopup.getPopupObj("last");
    var uitype = ld(obj).attr('uitype');
    var chebox_objs = ld('#'+popupobj.divid+' [name=set_default]');
    if(uitype != 33 && ld(obj).prop('checked')){
        chebox_objs.prop('checked',false);
        ld(obj).prop('checked',true);
    }
    
}