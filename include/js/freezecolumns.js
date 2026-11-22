/**
 * 表头的th每个都要有thindex   固定到此列的th需要有class   传参
 * 表体的td每个都要有tdindex   固定到此列的td需要有class   传参
 *
 * 表格边框线需要改成 box-shadow: inset  1px 1px  1px #ddd;
 * @constructor
 */
function FreezeColumns (){
    this.tableid = "";
    var that = this;
    this.popupobj = "";
    this.divid = "";
    this.init = function(tableid) {
        that.tableid = tableid;
        that.popupobj = CrmPopup.getPopupObj("last");
        if(that.popupobj!=""&&that.popupobj!=undefined){
            that.divid = that.popupobj.divid;
        }else{
            that.divid = "customtable_content";//链接模块
        }
    }
    this.setpopupobj = function(popupobj,divid){
        that.popupobj = popupobj;
        that.divid = divid;
    }
    //冻结列--当前列的前面所有列
    //td的列索引  tdindex
    //冻结的class名称
    this.freezeTdColumnBeforeAll = function(classname,width){
        //获取th的left 值组合
        var set_sticky_tds = ld('#'+that.divid+' #'+that.tableid+' td.'+classname);
        if(set_sticky_tds.length<=0){
            return;
        }
        ld.each(set_sticky_tds,function(i,tdobj){
            var trobj = Tools.getParentobjByChild(ld(tdobj),'tr');
            var backcolor = ld(trobj).css('background-color');

            var prevall_tds = ld(tdobj).prevAll();
            var cur_tdindex = ld(tdobj).attr('tdindex');
            ld.each(prevall_tds,function(j,prevobj) {
                var tdindex = ld(prevobj).attr('tdindex');
                var backcolor_td = ld(prevobj).css('background-color');
                if(backcolor_td==''||backcolor_td=='rgba(0, 0, 0, 0)'){
                    backcolor_td = backcolor;
                }
                tdindex = parseInt(tdindex);
                cur_tdindex = parseInt(cur_tdindex);
                if(tdindex<cur_tdindex){
                    ld(prevobj).css('position','sticky')
                        .css('left',width[tdindex]+'px')
                        .css('background-color',backcolor_td)
                        .css('z-index','9901');
                }
            });
            var curbackcolor_td = ld(tdobj).css('background-color');
            if(curbackcolor_td==''||curbackcolor_td=='rgba(0, 0, 0, 0)'){
                curbackcolor_td = backcolor;
            }
            ld(tdobj).css('position','sticky')
                .css('left',width[cur_tdindex]+'px')
                .css('background-color',curbackcolor_td)
                .css('z-index','9901');
            ld(trobj).css('z-index','9900');
            ld(tdobj).addClass('boxshadow')
        });
    }
    this.freezeThColumnBeforeAll = function(classname){
        var set_sticky_th = ld('#'+that.divid+' #'+that.tableid+' th.'+classname);
        if(set_sticky_th.length<=0){
            return;
        }
        var width = new Array();
        var cur_left = 0;
        var trobj = Tools.getParentobjByChild(ld(set_sticky_th),'tr');
        var cur_backcolor = ld(set_sticky_th).css('background-color');
        var prevall_ths = ld(set_sticky_th).siblings();
        var cur_thindex = ld(set_sticky_th).attr('thindex');
        ld.each(prevall_ths,function(j,prevobj) {
            var backcolor = ld(prevobj).css('background-color');
            j = parseInt(j);
            cur_thindex = parseInt(cur_thindex);
            if(j<cur_thindex){
                if(j==0){
                    width.push(cur_left);
                }
                ld(prevobj).css('position','sticky')
                    .css('left',cur_left+'px')
                    .css('background-color',backcolor)
                    .css('z-index','10000');
                var cur_width = ld(prevobj).width();
                cur_left = cur_left+parseInt(cur_width)+5;
                width.push(cur_left);
            }
        });

        ld(set_sticky_th)
            .css('position','sticky')
            .css('left',cur_left+'px')
            .css('background-color',cur_backcolor)
            .css('z-index','10000');
        width.push(cur_left);
        ld(trobj).css('z-index','9999');
        ld(set_sticky_th).addClass('boxshadow');
        return width;
    }
    //解除固定列--所有的
    this.unfreezeAll = function(){
        var thobjs = ld('#'+that.divid+' #'+that.tableid+' th');
        thobjs.removeClass('boxshadow').removeClass('set-sticky').css('position','');
        var tdobjs = ld('#'+that.divid+' #'+that.tableid+' td');
        tdobjs.removeClass('boxshadow').removeClass('set-sticky').css('position','').css('background-color','');
    }
    //给当前列增加固定列的class
    this.addSticky = function(self){
        var thobj = Tools.getParentobjByChild(self,'th');
        ld(thobj).addClass('set-sticky');
        var thindex = ld(thobj).attr('thindex');
        ld('#'+that.divid+'#'+that.tableid+' td[tdindex='+thindex+']').addClass('set-sticky');
    }
}
var freezecolumnsObj = new FreezeColumns();