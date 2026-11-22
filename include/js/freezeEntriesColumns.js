/**
 * 单据分录冻结类
 * 表格边框线需要改成 box-shadow: inset  1px 1px  1px #ddd;
 * 明细分录冻结的类
 * @constructor
 */
function FreezeEntriesColumns (popupobj,tableid){
    var that = this;
    that.tableid = tableid;
    that.popupobj = popupobj;
    that.divid = popupobj.divid;
    that.isshouldFreeze = 'yes';//是否执行冻结
    that.positionLeftWidthArr = [];//冻结的每一列的left值/width值
    that.stickyindex = 0;//冻结的每一列的left值
    that.trheadobj = [];//表头tr的obj
    that.allvibible_ths = [];//表头td的objs
    that.init = function() {
        //获取data-stickyindex
        that.stickyindex = ld('#'+that.divid).find("#"+that.tableid+" tr[tag=trhead]").data('stickyindex');
        if(popupobj.module=='WorkSheet'){
            that.stickyindex = that.stickyindex+1;
        }
        //判断是否有滚动条  有滚动条才做冻结
        var tableobjwidth = ld('#'+that.divid).find('#'+that.tableid).attr('tablewidth');
        var divobjwidth = ld('#'+that.divid).find('#'+that.tableid).find('[name=table_width]').val();
        if(tableobjwidth!=divobjwidth||that.stickyindex==0){
            that.isshouldFreeze = 'no';
        }

    }
    //获取每一列的left值  是一个数组 [0,100,180,280.....]
    that.getPositionLeftArr = function(){
        that.init();
        if(that.isshouldFreeze=='no'){
            return;
        }
        var trobj = ld('#'+that.divid).find("#"+that.tableid+" tr[tag=trhead]");//表头行tr

        that.trheadobj = trobj;

        var allvibible_ths = ld(trobj).find("td:last").siblings(':visible');//获取表头的所有可见兄弟元素
        that.allvibible_ths = allvibible_ths;
        var cur_left = 0;
        var positionLeftWidthArr = [];//冻结的每一列的left值/width值

        ld.each(allvibible_ths,function(i,thobj) {
            if(i<parseInt(that.stickyindex)+1){
                var cur_width = ld(thobj).outerWidth();
                var tmparr = {'width':cur_width,'left':cur_left};
                positionLeftWidthArr.push(tmparr);
                cur_left = cur_left+parseInt(cur_width);
            }
        });
        //zxm 20230822 收款单-没有分录的时候 冻结会报错 
        if(positionLeftWidthArr.length<=0){
            that.isshouldFreeze='no';
        }
        that.positionLeftWidthArr = positionLeftWidthArr;
    }
    //冻结表头的
    that.freezeHeaderColumn = function(){
        if(that.isshouldFreeze=='no'){
            return;
        }
        if(ld(that.trheadobj).css('top') && !empty(ld(that.trheadobj).css('top'))){
            var sticky_top = ld(that.trheadobj).css('top');
        }else{
            var sticky_top = '0px';
        }
        //zxm 20231030 冻结表头列的时候  先冻结表头行
        ld(that.trheadobj).css('position', 'sticky')
            .css('top', sticky_top)
            .css('background-color', ld(that.trheadobj).css('background-color'))
            .css('z-index', "100000");
        ld.each(that.allvibible_ths,function(i,thobj) {
            if(i<parseInt(that.stickyindex)+1){
                var tmparr = that.positionLeftWidthArr[i];
                var backcolor = ld(thobj).css('background-color');
                that.setTdCssSticky(tmparr['left'],tmparr['width'],backcolor,"100000",thobj);
                //最后一列样式不同
                if(i==parseInt(that.stickyindex)){
                    ld(thobj).addClass('boxshadow');
                }

            }
        });
    }
    //冻结多行表体的 传过来trobjs  参数1是tr的数组 如果是1个tr也是一个数组
    //---新增分录行的时候可以只调用这个方法即可
    that.freezeTbodyColumn = function(tbodytrobjs,prevzindex=99998){
        if(that.isshouldFreeze=='no'){
            return;
        }
        var initindex=prevzindex-1;
        ld.each(tbodytrobjs,function(i,trobj){
            var all_tds = ld(trobj).find('td:visible');
            ld.each(all_tds,function(j,tdobj) {
                var backcolor = ld(tdobj).parent().css('background-color');
                backcolor = backcolor=="rgba(0, 0, 0, 0)"?'#fff':backcolor;
                if(j<=that.stickyindex){
                    var tmparr = that.positionLeftWidthArr[j];
                    that.setTdCssSticky(tmparr['left'],tmparr['width'],backcolor,initindex,tdobj);
                    if(j==that.stickyindex){
                        ld(tdobj).addClass('boxshadow')
                    }


                    initindex = initindex-1;
                }
            });
            initindex = initindex-1;
        });
        that.setLastColCss(ld('#'+that.divid+' #'+that.tableid).parent());
    }




    //初始化冻结 包含冻结表头和表体
    that.freezeTheadAndBody = function(){
        if(that.isshouldFreeze=='no'){
            return;
        }
        that.unfreezeAll();//取消所有冻结 初始化
        that.getPositionLeftArr();//获取冻结列的left值和width值
        that.freezeHeaderColumn();//冻结表头
        var popupobj = CrmPopup.getPopupObj('last');
        if(popupobj.pagetype == 'detailview_modulepage'){
            var alltbodytrs = ld('#'+that.divid+' #'+that.tableid).find('tr:gt(0)');//详情页面获取索引值大于0的tr
        }else{
            var alltbodytrs = ld('#'+that.divid+' #'+that.tableid).find('tr:gt(1)');//获取索引值大于1的tr
        }
        that.freezeTbodyColumn(alltbodytrs,99998);
        that.setScrollEvent();
    }
    //设置冻结列td或者th的样式
    that.setTdCssSticky = function(left,width,backcolor,zindex,tdobj){
        ld(tdobj).css('position', 'sticky')
            .css('left', left+ 'px')
            //.css('min-width',  width+ 'px')//zxm 20231023 这行导致冻结列的宽度变化 拖动会往前缩一点
            .css('background-color', backcolor)
            .css('z-index', zindex);
    }
    //设置滚动事件
    that.setScrollEvent = function(){
        ld('#'+that.divid+' #'+that.tableid).parent().scroll(function(){
            that.setLastColCss(this);
        });
    }
    //设置最后一列的样式
    that.setLastColCss = function(obj){
        var left  = ld(obj).scrollLeft();
        if(left>0){
            ld('#'+that.divid+' #'+that.tableid).find('.boxshadow').css('background-image','linear-gradient(-90deg, #ddd 0px,  #ddd 1px, transparent 2px)');
        }else{
            ld('#'+that.divid+' #'+that.tableid).find('.boxshadow').css('background-image','');
        }
    }
    //解除固定列--所有的--咱
    that.unfreezeAll = function(){
        var thobjs = ld('#'+that.divid+' #'+that.tableid+' th');
        //thobjs.removeClass('boxshadow').removeClass('set-sticky').css('position','');
        //BUG20240618-12 费用报销单新建，报销类型选择其他，分录错行
        thobjs.removeClass('boxshadow').css('position','').css('left','');
        var tdobjs = ld('#'+that.divid+' #'+that.tableid+' td');
        //tdobjs.removeClass('boxshadow').removeClass('set-sticky').css('position','').css('background-color','');
        //BUG20240618-12 费用报销单新建，报销类型选择其他，分录错行
        tdobjs.removeClass('boxshadow').css('position','').css('background-color','').css('left','');
    }
}
