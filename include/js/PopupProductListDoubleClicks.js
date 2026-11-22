/*
editer:ljj
time:20231103
reason:XUQIU1001640
content:选择源单弹出层界面，增加“选中某个单据的产品时自动勾选该单据所有明细行”参数（徐昱轩）
*/
function PopupProductListDoubleClicks(popupobj){
    this.popupobj=popupobj;
    if (popupobj == undefined){
        this.popupobj=CrmPopup.getPopupObj('last');
    }
    var that=this;
    this.tdobj = ld("#"+this.popupobj.divid).find("td[ispopupdoubleclick=yes]");
    this.popupdoubleclickobj = ld("#popupdoubleclick");
    this.input=ld(this.tdobj).parent('tr').find('td.firstChild');

    //设置双击选中全部明细或反选、提示悬浮事件
    this.setProductListDoubleClickEvent=function()
    {
        if(that.tdobj.length==0 || that.input.length == 0){
            //无复选框或未设置可双击区域
            return ;
        }
        if (that.popupdoubleclickobj.length== 0){
            ld("body").append('<div class="popupdoubleclick" id="popupdoubleclick" name="popupdoubleclick" style="display: none"></div>')
            that.popupdoubleclickobj=ld("#popupdoubleclick");
            ld(that.popupdoubleclickobj).text(arrJsPopLabel['PopupProductListDoubleClick']);
        }
        ld(that.tdobj).each(function (){
            //鼠标悬浮事件
            ld(this).unbind('mousemove').bind('mousemove',function (event){
                var e=e || window.event;
                ld(that.popupdoubleclickobj).css('left',(e.pageX + 20) + 'px');
                ld(that.popupdoubleclickobj).css('top',(e.pageY -5 )+ 'px');
                //让浮窗z值高于详细页弹出层
                var zindex = ld("#"+that.popupobj.divid).css('z-Index');
                if(that.popupobj.type == 'selectsearchdetail' && ld.isNumeric(zindex) == true){
                    ld(that.popupdoubleclickobj).css('z-index',parseInt(zindex)+1);
                }else{
                    ld(that.popupdoubleclickobj).css('z-index',1100);
                }
                //光标移到span上时就隐藏浮窗
                var nodeName=event.target.nodeName.toLocaleLowerCase();
                if(nodeName != 'span' && nodeName !='a' ){
                    ld(that.popupdoubleclickobj).show();
                }
                else{
                    ld(that.popupdoubleclickobj).hide();
                }
                // StopEvent(event.originalEvent);
            });

            //鼠标离开事件
            ld(this).unbind('mouseleave').bind('mouseleave',function (event){
                ld(that.popupdoubleclickobj).css('display','none');
                // StopEvent(event.originalEvent);
            });
            //双击全选或者反选明细事件
            var record=ld(this).parent('tr').attr('record');
            ld(this).unbind('dblclick').bind('dblclick',function (event){
                //zkt 20240805 BUG20240730-45 采购CRM 采购发票模块，勾选源单“采购合同”时，选择源单带出的分录有问题，不太好描述，请参考附件的视频（潘：选择源单界面，双击选择多产品分录的源单后，再次双击选择同一个源单后，只带出了一个分录明细，kfbcrm也有这个问题）---8624是否可以提供一个补丁
                var detailinput=ld("#"+that.popupobj.divid).find("[record="+record+"] input[type=checkbox]");
                var isallchecked=true;
                // ljj 20231121 BUG0075799 双击选中分录有521条的单据无效卡死
                detailinput.each(function (){
                    if (ld(this).prop('checked') == false){
                        isallchecked=false;
                        return false;
                    }
                });
                detailinput.each(function (){
                    //分录过多使用click主动点击会卡死
                    detailinput.prop('checked',!isallchecked);
                    fun_setCrmPopupWindow.setChooseInfo_arr(ld(this));
                })
            });
        });

    }
    this.setProductListDoubleTip=function (){
        that.tdobj = ld("#"+this.popupobj.divid).find("tr[ispopupdoubleclick=yes]");
        if(that.tdobj.length==0 ){
            //无复选框或未设置可双击区域
            return false;
        }
        if (that.popupdoubleclickobj.length== 0){
            ld("body").append('<div class="popupdoubleclick" id="popupdoubleclick" name="popupdoubleclick" style="display: none"></div>')
            that.popupdoubleclickobj=ld("#popupdoubleclick");
            ld(that.popupdoubleclickobj).text(arrJsPopLabel['DOUBLECLICKTOSELECTDOCUMENT']);
        }
        ld(that.tdobj).each(function (){
            //鼠标悬浮事件
            ld(this).unbind('mousemove').bind('mousemove',function (event){
                var e=e || window.event;
                ld(that.popupdoubleclickobj).css('left',(e.pageX + 20) + 'px');
                ld(that.popupdoubleclickobj).css('top',(e.pageY -5 )+ 'px');
                //让浮窗z值高于详细页弹出层
                var zindex = ld("#"+that.popupobj.divid).css('z-Index');
                if(ld.isNumeric(zindex) == true){
                    ld(that.popupdoubleclickobj).css('z-index',parseInt(zindex)+1);
                }else{
                    ld(that.popupdoubleclickobj).css('z-index',1100);
                }
                //光标移到span上时就隐藏浮窗
                var nodeName=event.target.nodeName.toLocaleLowerCase();
                if(nodeName != 'span' && nodeName !='a' ){
                    ld(that.popupdoubleclickobj).css('display','');
                }
                else{
                    ld(that.popupdoubleclickobj).css('display','none');
                }
                // StopEvent(event.originalEvent);
            });

            //鼠标离开事件
            ld(this).unbind('mouseleave').bind('mouseleave',function (event){
                ld(that.popupdoubleclickobj).css('display','none');
                // StopEvent(event.originalEvent);
            });
        });
    }
    this.removeDoubleTip = function (){
        if (that.popupdoubleclickobj.length != 0){
            ld(that.popupdoubleclickobj).remove();
        }
    }

}