function Entriespaging() 
{
    var that = this;
    var popupobj;
    var showdetailrowcnt=40;//页面显示分录总条数，默认40;
    var cur_maxrowindex;
    var scrollTop;
    
    this.initpaging = function(popupobj){
        this.popupobj = popupobj;
        this.module = popupobj.module;
        if(popupobj.showdetailrowcnt !=undefined){
            that.showdetailrowcnt = popupobj.showdetailrowcnt;
        }
        if(popupobj.detailfieldmodule == 'Products'){
            this.detailmodule = 'Products';
            this.scrollobjname = 'productDiv';
        }
        else{
            return ;
        }
        this.setscrollEvent();
    }
    
    this.getcur_maxrowindex = function(){
        var popupobj = that.popupobj;
        if(empty(that.cur_maxrowindex)&&popupobj.pagetype != undefined && popupobj.pagetype == "create_edit_modulepage"){
            var rowobjs = popupobj.getTrObjsByDelType('no');
            if(rowobjs.length>0){
                var showlasttr = ld(rowobjs).eq(-1);
                that.cur_maxrowindex = parseInt(ld(showlasttr).attr('rowindex'));
            }
        }
        console.log(that.cur_maxrowindex);
        return that.cur_maxrowindex;
    }
    
    //绑定滚动条事件
    this.setscrollEvent = function () {
        var popupobj = this.popupobj;
        var scrollobjname = this.scrollobjname;
        this.scrollTop = ld("#"+popupobj.divid + " [name="+scrollobjname+"]").get(0).scrollTop;
      
        ld("#"+popupobj.divid + " [name="+scrollobjname+"]").scroll(function(event){
            //console.log(event);
            var beforescrollTop = that.scrollTop;
            var scrollTop = ld(this).get(0).scrollTop;
            that.scrollTop = scrollTop;
            var scrollTopMax = ld(this).get(0).scrollTopMax;
            that.getcur_maxrowindex();
            if(!empty(ld("tr[rowindex=20000]"))){
                that.rowhtml = ld('#productrow_20000').prop("outerHTML");
            }
            if(empty(that.rowhtml)){
                popupobj.selectproductobj.AddRowByRowIndex(20000);
                ld("tr[rowindex=20000]").attr(("id"), "productrow_20000");
                that.rowhtml = ld('#productrow_20000').prop("outerHTML");
            }
            var cur_maxrowindex = that.cur_maxrowindex;
            var showdetailrowcnt = empty(that.showdetailrowcnt)?40:that.showdetailrowcnt;
            var detailsubtotalheight = 46;//小计行高度 
            if(ld(this).find(' [name=detail_subtotal_row]').length>0){
                detailsubtotalheight = ld(this).find(' [name=detail_subtotal_row]').height();
            }
            //滚动到最下面
            if(scrollTop+detailsubtotalheight+42>=scrollTopMax&&scrollTop>beforescrollTop){
                if(popupobj.detaildatavalue_arr == undefined){
                    return ;
                }
                //判断是否加载到最后一个tr：界面显示的最大rowindex小于数据长度，则数据没有加载完毕，未加载到最后一行
                if(popupobj.detaildatavalue_arr.length>cur_maxrowindex){
                    that.showRow_havedata(cur_maxrowindex+1,'end');
                    if(scrollTop>=scrollTopMax-detailsubtotalheight-42){
                    ld(this).get(0).scrollTop = scrollTop-2;
                     }
                     
                }
            }
            //滚动到最上面
            else if(scrollTop<=20){
                //判断是否加载到第一个tr：界面显示的最大rowindex-显示行最大数>0，则数据没有加载至第一行
                if(cur_maxrowindex-showdetailrowcnt>0){
                    that.showRow_havedata(cur_maxrowindex-showdetailrowcnt,'start');
                    ld(this).get(0).scrollTop = scrollTop+5;
                }
            }
        })
    }
    
    //绑定滚动条事件
    this.showRow_havedata = function (rowindex,position) {
        if(this.detailmodule == 'Products'){
            this.showproductsRow_havedata(rowindex,position);
        }
    }
    // rowindex被插入行的rowindex ,position：strat在上面插入行,end在下面插入行
    this.showproductsRow_havedata = function (rowindex,position) {
        var popupobj = that.popupobj;
         
        if(popupobj.pagetype != undefined && popupobj.pagetype == "detailview_modulepage"){
            //详情页滚动事件
            that.showdetailproductsRow_havedata(rowindex,position);
        }
        if(that.popupobj.module=="WorkSheet")
        {
            return ;   
        }
        var showdetailrowcnt = empty(that.showdetailrowcnt)?40:that.showdetailrowcnt;
        
        
        //添加新行
        rowhtml = that.rowhtml;
        if(position == 'end'){
            console.log('下面添加新行');
            //console.log('删除最上面一行');
            //下面添加新行
            var actualastlindex = showdetailrowcnt+1;
          //   ld("#" + popupobj.divid + " [name=proTab] > tbody > tr:eq(" + eval(actualastlindex+1) + ")").css("display",'');
            //  that.cur_maxrowindex=that.cur_maxrowindex+1;
            // return false;
            var actuafirstlindex = 2;
            if (popupobj.js_detailtablename == 'newproTab') {
                ld("#" + popupobj.divid + " [name=newproTab] > tbody > tr:eq(" + eval(actualastlindex) + ")").after(rowhtml);
                ld("#" + popupobj.divid + " [name=proTab] > tbody > tr:eq(" + eval(actuafirstlindex) + ")").remove();
            } else {
                ld("#" + popupobj.divid + " [name=proTab] > tbody > tr:eq(" + eval(actualastlindex) + ")").after(rowhtml);
                ld("#" + popupobj.divid + " [name=proTab] > tbody tr:eq(" + eval(actuafirstlindex) + ")").remove();
                var rowobj = ld("#" + popupobj.divid + " [name=proTab]").find("#productrow_20000");
                ld(rowobj).attr("rowindex", rowindex)
                    .attr("name", "row" + rowindex).find("#td_seqno").html(rowindex);
                ld(rowobj).attr("id", '');
            }
            popupobj.detaildatavalue_arr[rowindex-1].databind = 'no';//新增行databind设置为no
            popupobj.detaildatavalue_arr[rowindex-showdetailrowcnt-1].databind = 'no';//删除行databind设置为no
            that.cur_maxrowindex=that.cur_maxrowindex+1;
        }
        else if(position == 'start'){
            console.log('上面添加新行');
            //console.log('删除最下面一行');
            var actualastlindex = showdetailrowcnt+1;
            var actuafirstlindex = 2;
            if (popupobj.js_detailtablename == 'newproTab') {
                ld("#" + popupobj.divid + " [name=newproTab] > tbody > tr:eq(" + eval(actuafirstlindex) + ")").before(rowhtml);
                ld("#" + popupobj.divid + " [name=proTab] > tbody > tr:eq(" + eval(actualastlindex+1) + ")").remove();//已经增加了行，被删除行index要加1
            } else {
                ld("#" + popupobj.divid + " [name=proTab] > tbody > tr:eq(" + eval(actuafirstlindex) + ")").before(rowhtml);
                ld("#" + popupobj.divid + " [name=proTab] > tbody > tr:eq(" + eval(actualastlindex+1) + ")").remove();//已经增加了行，被删除行index要加1
                var rowobj = ld("#" + popupobj.divid + " [name=proTab]").find("#productrow_20000");
                ld(rowobj).attr("rowindex", rowindex)
                    .attr("name", "row" + rowindex).find("#td_seqno").html(rowindex);
                ld(rowobj).attr("id", '');
            }
            popupobj.detaildatavalue_arr[rowindex-1].databind = 'no';//新增行databind设置为no
            popupobj.detaildatavalue_arr[rowindex+showdetailrowcnt-1].databind = 'no';//删除行databind设置为no
            that.cur_maxrowindex=that.cur_maxrowindex-1;
        }
        
        //赋值，新增编辑界面未显示行
        if(popupobj.pagetype != undefined && popupobj.pagetype == "create_edit_modulepage"){
            var tableobj = popupobj.getDetailTableObj();
            var tmpdetaildatavalue_arr = new Array();
            var tmpdetaildatavalue_objarr = popupobj.detaildatavalue_arr[rowindex-1];
            ld.each(tmpdetaildatavalue_objarr,function(tmpkey,tmpval){
                if(tmpkey == 'databind')return true;
                tmpdetaildatavalue_arr.push(tmpkey);
                tmpdetaildatavalue_arr.push(tmpval);
            })
            var rowobj = ld(tableobj).find("tr[rowindex=" + rowindex + "]");
            
            //先移过来不知道干嘛的
            if (popupobj.selectproductobj.cur_module == 'QuotesChange' || popupobj.selectproductobj.cur_module == 'BudgetChange') {
                if (CrmPopup.findHtmlobj(popupobj.divid, 'change_type').val() != undefined && CrmPopup.findHtmlobj(popupobj.cur_divid, 'change_type').val() == 'replace') {
                    return false;
                }
            }
            
            popupobj.selectproductobj.setDataBind(rowobj);//数据绑定
            popupobj.SetDetailFieldControl(rowindex);
            for(var i=0;i<tmpdetaildatavalue_arr.length;i=i+2){
                var tmpkey = tmpdetaildatavalue_arr[i];
                var tmpval = tmpdetaildatavalue_arr[i+1];
                popupobj.detaildatavalue_arr[rowindex-1][tmpkey]=tmpval;
            }
            //特殊字段赋值 : 可能存在的 图片、批次
            //批次
            if(popupobj.detaildatavalue_arr[rowindex-1]['producthave_batchtext'] != undefined  && popupobj.detaildatavalue_arr[rowindex-1]['producthave_batchtext'] == 'yes'){
                ld(rowobj).find(" [name=batchtext]").css("display", 'inline');
                ld(rowobj).find(" [name=searchbatchtextIcon]").css('display', 'inline');
                ld(rowobj).find(" [name=clearbatch]").css('display', 'inline');
            }
            /*
            ld.each(popupobj.detailfields, function (tmpindex, tmpinfo) {
                if (tmpinfo.edit_permission == 2 || ((tmpinfo.edit_permission==3||tmpinfo.edit_permission==1)&&
                    tmpinfo.uitype!=200 &&tmpinfo.uitype!=202&&tmpinfo.uitype!=204 &&tmpinfo.uitype!=205&&tmpinfo.uitype!=201)) {
                    if(popupobj.detaildatavalue_arr[rowindex - 1]!=undefined&&popupobj.detaildatavalue_arr[rowindex - 1][tmpinfo.columnname]!=undefined
                    &&(popupobj.detaildatavalue_arr[rowindex - 1][tmpinfo.columnname+"_name"] == undefined ||popupobj.detaildatavalue_arr[rowindex - 1][tmpinfo.columnname+"_name"] != popupobj.detaildatavalue_arr[rowindex - 1][tmpinfo.columnname])){
                        popupobj.detaildatavalue_arr[rowindex - 1][tmpinfo.columnname+"_name"] = popupobj.detaildatavalue_arr[rowindex - 1][tmpinfo.columnname];
                    }
                }else  if(tmpinfo.uitype == 100)
                {
                    //ld(rowobj).find("#" + tmpinfo.columnname + "_name").val(popupobj.detaildatavalue_arr[rowindex - 1]);
                }
                else  if(tmpinfo.uitype==60 &&tmpinfo.columnname=='wareid')
                {
                    //ld(rowobj).find("#" + tmpinfo.columnname + "_name").val(popupobj.detaildatavalue_arr[rowindex - 1]);
                }
                else  if(tmpinfo.uitype==60)
                {
                    //ld(rowobj).find("#" + tmpinfo.columnname + "_name").val(popupobj.detaildatavalue_arr[rowindex - 1]);
                }
                else if (tmpinfo.columnname == 'entitytype' || tmpinfo.columnname == 'entitytypeid'){
                    
                }
                
            })
            */
        }
        getJsScript('include/js/freezeEntriesColumns.js', function () {
            var freezeEntriesColumnsobj = new FreezeEntriesColumns(popupobj,'proTab');
            //这里不需要重新冻结所有 只需要冻结新增行即可
            freezeEntriesColumnsobj.getPositionLeftArr();//获取宽度数组
            var rowindex = ld(rowobj).attr("rowindex");
            var detailfieldname = ld(popupobj.getDetailTableObj()).find("tr[tag=trhead]").find('.set-sticky').attr("head_detailfieldname");
            freezeEntriesColumnsobj.freezeTbodyColumn(rowobj,);
            if (parseInt(rowindex) == 1)
                freezeEntriesColumnsobj.freezeTbodyColumn(rowobj, ld(popupobj.getDetailTableObj()).find("tr[tag=trhead]").find('.set-sticky').css('zIndex'));
            else
                freezeEntriesColumnsobj.freezeTbodyColumn(rowobj,  ld(popupobj.getDetailTableObj()).find(" tr[rowindex=" + (rowindex - 1) + "]").find("td[detailfieldname=" + detailfieldname + "]").css('zIndex'));
        });
        //设置冻结列事件
        // getJsScript('include/js/freezecolumns.js', function () {
        //     freezecolumnsObj.init('proTab');//冻结列类初始化
        //     var detailfieldname = ld(popupobj.getDetailTableObj()).find("tr[tag=trhead]").find('.set-sticky').attr("head_detailfieldname");
        //     if (parseInt(rowindex) == 1)
        //         freezecolumnsObj.freezeThColumn('set-sticky', rowobj, ld(popupobj.getDetailTableObj()).find("tr[tag=trhead]").find('.set-sticky').css('zIndex'));
        //     else
        //         freezecolumnsObj.freezeThColumn('set-sticky', rowobj, ld(popupobj.getDetailTableObj()).find(" tr[rowindex=" + (rowindex - 1) + "]").find("td[detailfieldname=" + detailfieldname + "]").css('zIndex'));
        // });
    }
    
    //详情页滚动触发事件
    this.showdetailproductsRow_havedata = function (rowindex,position) {
        
    }
    
}