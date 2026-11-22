//wym 20230228 双击浮窗
function ListDoubleClick(listpopupobj)
{
    this.listpopupobj=listpopupobj;
    var that=this;
    this.aobj = ld("#"+this.listpopupobj.divid).find("a[doubleclick=yes]");
    this.floatdetailobj = ld("div[id=floatdetail]");
    //已存在浮窗时，重置界面
    this.resetPopupobj = function(obj){
        that.listpopupobj=obj;
        this.setDoubleClickEvent();
    }

    this.setDoubleClickEvent=function()
    {
        //return;
        if(this.aobj.length<=0){
            return ;
        }
        if(ld(that.floatdetailobj).length>0) {
            ld(that.floatdetailobj).css("display",'none');
        }
        //为每个a标签对象循环绑定
        ld.each(this.aobj,function () {
            var parenttdobj = Tools.getParentobjByChild(ld(this),'td');
            //鼠标移入事件
            ld(parenttdobj).bind("mousemove",function(event){
                ld("#pageleft .menu-thumbnail-box").hide();
                var e = e||window.event;
                //var text = ld(this).find("a").text(); 路总说标题太长,显示不好看,不要了
                if(ld(that.floatdetailobj).length<=0) {
                    ld("body").append('<div class="double-click-float floattext" id="floatdetail" name="floatdetail" ></div>');
                }
                that.floatdetailobj = ld("div[id=floatdetail]");
                ld('.floattext').text(arrJsPopLabel['DOUBLECLICKTOSEEDETAILS']);
                ld(that.floatdetailobj).css("left",e.pageX + 'px');
                ld(that.floatdetailobj).css("top",(e.pageY + 20 ) + 'px');
                //让浮窗z值高于详细页弹出层
                var zindex = ld("#"+that.listpopupobj.divid).css('z-Index');
                if(that.listpopupobj.type == 'relatelistpage' && ld.isNumeric(zindex) == true){
                    ld(that.floatdetailobj).css("z-index",parseInt(zindex)+1);
                }else{
                    ld(that.floatdetailobj).css("z-index",1100);
                }
                //光标移到a链接上时就隐藏浮窗
                if(event.target.nodeName.toLocaleLowerCase() != 'a'){
                    ld(that.floatdetailobj).show();
                }
                else{
                    ld(that.floatdetailobj).hide();
                }
                StopEvent(event.originalEvent);
            })
            //双击进入详情页事件
            ld(parenttdobj).unbind("dblclick").bind("dblclick",function(event){
                var clickobj = ld(this).find("a[doubleclick=yes]");
                if((clickobj.length) > 0){
                    //duan 20240506 避免列表超链接重复点击时,单击和双击事件同时触发的问题
                    if(!empty(event.target) && event.target == clickobj.get(0)){
                        return ;
                    }
                    clickobj.click();
                    ld(that.floatdetailobj).css("display",'none');
                }
            })
            //鼠标移出事件
            ld(parenttdobj).bind("mouseleave",function(e){
                //BUG0069733 txy 20230721 kfbcrm:客户相关信息列表，鼠标在编号字段上下移动时，选中效果不会消失，其他字段没有问题
                if(ld(this).parent().get(0).onmouseout.length > 0){
                    // wym 240129 BUG20240126-33 隔行换色的行需要传值传On
                    if (ld(this).parent().hasClass('lvtColData')) {
                        listOnMouseOut(ld(this).parent(),'on','record');
                    } else {
                        listOnMouseOut(ld(this).parent(),'On','record');
                    }
                }
                var tdwidth = ld(this).width();
                var tdheight = ld(this).height();
                //var e = e||window.event;
                //var x = (e && e.layerX) || window.event.offsetX;//获取鼠标相对于当前元素的位置X
                //var y = (e && e.layerY) || window.event.offsetY;//获取鼠标相对于当前元素的位置Y
                ld(that.floatdetailobj).css("display",'none');
                StopEvent(e.originalEvent);
            })
        });
    }
}
