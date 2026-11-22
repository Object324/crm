function StyleSet (){
    var that = this;
    var divid;//编辑报表弹框的divid
    var createObj;
    this.styleSetPop = function(divid,obj,createObj){
        that.divid = divid;
        that.createObj = createObj;
        var tmpwidth = "800px";
        var module = 'CustomTables';
        var Popupobj = CrmPopup.load(arrJsPopLabel['StyleSettings'], that.saveStyleSet, "", tmpwidth, module, "", arrJsPopLabel['Confirm'], "", arrJsPopLabel['CANCEL']);
        Popupobj.createScrollDiv();//创建滚动条
        Popupobj.prevshow();
        Popupobj.setParams(arrJsPopLabel['StyleSettings'], that.saveStyleSet, '', tmpwidth, module, "", arrJsPopLabel['Confirm'], "",  arrJsPopLabel['CANCEL']);
        var content = ld('#'+divid).find('#styleSet').prop("outerHTML")
        Popupobj.show('<div class="customtable-content">'+content+'</div>');

        divid = Popupobj.divid;//新的弹框的divid
        //获取样式设置的值
        var thobj = Tools.getParentobjByChild(obj,'th');
        var tagname = thobj.find('input[name="columns[]"]').val();
        ld('#'+divid).find('#styleSet input[name="tagname"]').val(tagname);
        var styleset_header = thobj.find('input[name="styleset_header[]"]').val();
        //styleset_header = "background-color:red;color:#333;font-size:18px;font-weight:bolder;";
        if(styleset_header!=''){
            styleset_header = styleset_header.split(';');
            ld.each(styleset_header,function(i,item){
                if(item!=''){
                    item = item.split(':');
                    if(item[0]=='background-color'){
                        ld('#'+divid).find('#styleSet input[name="background_color_header"]').val(item[1]);
                        ld('#'+divid).find('#styleSet input[name="background_color_header"]').prev().attr('color',item[1]);
                        ld('#'+divid).find('#styleSet input[name="background_color_header"]').prev().css('background-color',item[1]);
                    }
                    if(item[0]=='color'){
                        ld('#'+divid).find('#styleSet input[name="font_color_header"]').val(item[1]);
                        ld('#'+divid).find('#styleSet input[name="font_color_header"]').prev().attr('color',item[1]);
                        ld('#'+divid).find('#styleSet input[name="font_color_header"]').prev().css('background-color',item[1]);
                    }
                    if(item[0]=='font-size'){
                        ld('#'+divid).find('#styleSet [name="font_size_header"] option[value="'+parseInt(item[1])+'"]').attr("selected",true);
                    }
                    if(item[0]=='font-weight'&&item[1]=='bolder'){
                        ld('#'+divid).find('#styleSet #font_bolder_header').prop('checked',true);
                    }else{
                        ld('#'+divid).find('#styleSet #font_bolder_header').removeAttr('checked');
                    }
                }
            });
        }
        var styleset_body = thobj.find('input[name="styleset_body[]"]').val();
        //styleset_body = "background-color:red;color:#333;font-size:18px;font-weight:bolder;";
        if(styleset_body!=''){
            styleset_body = styleset_body.split(';');
            ld.each(styleset_body,function(i,item){
                if(item!=''){
                    item = item.split(':');
                    if(item[0]=='background-color'){
                        ld('#'+divid).find('#styleSet input[name="background_color_body"]').val(item[1]);
                        ld('#'+divid).find('#styleSet input[name="background_color_body"]').prev().attr('color',item[1]);
                        ld('#'+divid).find('#styleSet input[name="background_color_body"]').prev().css('background-color',item[1]);
                    }
                    if(item[0]=='color'){
                        ld('#'+divid).find('#styleSet input[name="font_color_body"]').val(item[1]);
                        ld('#'+divid).find('#styleSet input[name="font_color_body"]').prev().attr('color',item[1]);
                        ld('#'+divid).find('#styleSet input[name="font_color_body"]').prev().css('background-color',item[1]);
                    }
                    if(item[0]=='font-size'){
                        ld('#'+divid).find('#styleSet [name="font_size_body"] option[value="'+parseInt(item[1])+'"]').attr("selected",true);
                    }
                    if(item[0]=='font-weight'&&item[1]=='bolder'){
                        ld('#'+divid).find('#styleSet #font_bolder_body').prop('checked',true);
                    }else{
                        ld('#'+divid).find('#styleSet #font_bolder_body').removeAttr('checked');
                    }
                }
            });
        }

        //颜色选择事件
        ld('#'+Popupobj.divid).find('div[name="color_div"]').unbind('click').bind('click',function(){
            var inputname = ld(this).next().attr('name');
            that.chooseColor(ld(this),inputname);
        });
        //恢复默认
        ld('#'+Popupobj.divid).find('#resetdefault').unbind('click').bind('click',function(){
            ld('#'+divid).find('#styleSet input[name="background_color_header"]').val("");
            ld('#'+divid).find('#styleSet input[name="background_color_header"]').prev().attr('color',"");
            ld('#'+divid).find('#styleSet input[name="background_color_header"]').prev().css('background-color',"#ddd");
            ld('#'+divid).find('#styleSet input[name="font_color_header"]').val("");
            ld('#'+divid).find('#styleSet input[name="font_color_header"]').prev().attr('color','');
            ld('#'+divid).find('#styleSet input[name="font_color_header"]').prev().css('background-color','#ddd');
            ld('#'+divid).find('#styleSet [name="font_size_header"] option').removeAttr("selected");
            ld('#'+divid).find('#styleSet #font_bolder_header').removeAttr('checked');

            ld('#'+divid).find('#styleSet input[name="background_color_body"]').val("");
            ld('#'+divid).find('#styleSet input[name="background_color_body"]').prev().attr('color',"");
            ld('#'+divid).find('#styleSet input[name="background_color_body"]').prev().css('background-color',"#ddd");
            ld('#'+divid).find('#styleSet input[name="font_color_body"]').val("");
            ld('#'+divid).find('#styleSet input[name="font_color_body"]').prev().attr('color','');
            ld('#'+divid).find('#styleSet input[name="font_color_body"]').prev().css('background-color','#ddd');
            ld('#'+divid).find('#styleSet [name="font_size_body"] option').removeAttr("selected");
            ld('#'+divid).find('#styleSet #font_bolder_body').removeAttr('checked');


        });
    }
    this.saveStyleSet = function(){
        var popupobj = CrmPopup.getPopupObj("last");
        var divid = popupobj.divid;
        var tagname = ld('#'+divid).find('[name=tagname]').val();
        var background_color_header = ld('#'+divid).find('[name=background_color_header]').val();
        var font_color_header = ld('#'+divid).find('[name=font_color_header]').val();
        var font_size_header = ld('#'+divid).find('[name=font_size_header]').val();
        var font_bolder_header = ld('#'+divid).find('[name=font_bolder_header]').prop('checked');
        var styleset_header = '';
        if(background_color_header!=''){
            styleset_header += 'background-color:'+background_color_header+';';
            ld('#'+that.divid).find('th[tag="'+tagname+'"]').css('background-color',background_color_header);
        }
        if(font_color_header!=''){
            styleset_header += 'color:'+font_color_header+';';
            ld('#'+that.divid).find('th[tag="'+tagname+'"]').css('color',font_color_header);
        }
        if(font_size_header!=''){
            styleset_header += 'font-size:'+font_size_header+'px;';
            ld('#'+that.divid).find('th[tag="'+tagname+'"]').css('font-size',font_size_header);
        }
        if(font_bolder_header!=''&&font_bolder_header==true){
            styleset_header += 'font-weight:bolder;';
            ld('#'+that.divid).find('th[tag="'+tagname+'"]').css('font-weight','bolder');
        }else{
            styleset_header  += 'font-weight:normal;';
            ld('#'+that.divid).find('th[tag="'+tagname+'"]').css('font-weight','normal');
        }



        var background_color_body = ld('#'+divid).find('[name=background_color_body]').val();
        var font_color_body = ld('#'+divid).find('[name=font_color_body]').val();
        var font_size_body = ld('#'+divid).find('[name=font_size_body]').val();
        var font_bolder_body = ld('#'+divid).find('[name=font_bolder_body]').prop('checked');
        var styleset_body = '';
        if(background_color_body!=''){
            styleset_body += 'background-color:'+background_color_body+';';
        }
        if(font_color_body!=''){
            styleset_body += 'color:'+font_color_body+';';
        }
        if(font_size_body !=''){
            styleset_body  += 'font-size:'+font_size_body +'px;';
        }
        if(font_bolder_body !=''&&font_bolder_body ==true){
            styleset_body  += 'font-weight:bolder;';
        }else{
            styleset_body  += 'font-weight:normal;';
        }



        ld('#'+that.divid).find('th[tag="'+tagname+'"] input[name="styleset_header[]"]').val(styleset_header);
        ld('#'+that.divid).find('th[tag="'+tagname+'"] input[name="styleset_body[]"]').val(styleset_body);
        popupobj.CancelEvent();
        that.createObj.saveReportInfo("no");
    }
    //选择颜色 zxm  2021-0618 下拉框颜色值的选择
    this.chooseColor = function(obj,inputname){
        var colpick_num = 1;
        var pick_color = ld(obj).attr('color');
        var css_type = pick_color==''||pick_color==undefined?'':pick_color;
        var tdobj =  Tools.getParentobjByChild(ld(obj),'td');
        var crmPopupobj=CrmPopup.load("","","","LdPopWidth600px",'Settings',"","","","");
        crmPopupobj.prevshow();
        var content='<link rel="stylesheet" href="themes/softed/colpick.css" type="text/css" /><div id="picker" name="picker" class="menu-colpick"></div>';
        getJsScript('include/js/colpick/colpick.js',function(){
            getJsScript('include/js/colpick/plugin.js',function(){
                crmPopupobj.setParams('选择颜色','',"","LdPopWidth350px",'Settings',"",'',"",'');
                crmPopupobj.show(content);
                var divid = crmPopupobj.divid;
                CrmPopup.findHtmlobj(divid,'picker').colpick({
                    color:css_type,
                    flat:true,
                    layout:'RGB',
                    submitText:'确认',
                    onSubmit:function(hsb,hex,rgb,el){//ok之后的确认事件
                        var _color = '#'+hex;
                        tdobj.find('input[name="'+inputname+'"]').val(_color);
                        ld(obj).attr('color',_color);//给input赋值颜色属性
                        ld(obj).css('background-color',_color);
                        crmPopupobj.CancelEvent();
                    }

                });
                var windowWidth = document.documentElement.clientWidth;
                var windowHeight = document.documentElement.clientHeight;
                if(colpick_num == 1)
                    var popupHeight = ld('#'+divid).height()-126;
                else{
                    var popupHeight = ld('#'+divid).height();
                }
                colpick_num++;
                var popupWidth = ld('#'+divid).width();
                ld('#'+divid).css({
                    "position": "fixed",
                    "top": (windowHeight-popupHeight)/2,   //+ld(document).scrollTop()明细界面的相关信息，滚动条到最下面，则弹出层显示错误
                    "left": (windowWidth-popupWidth)/2
                });
            });
        });
    }
}
