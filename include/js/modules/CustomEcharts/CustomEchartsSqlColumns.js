//统计字段设置
function CustomEchartsSqlColumns()
{
    this.tableobj=ld('#totalColumnList');
    this.chart_type='line';
    this.report_id = 0;
    this.ColumnsListObj = {};
    this.newButton = "yes";//判断是否有新增按钮
    this.popupobj = "";
    this.divid = "";
    this.sqlColumnsOptions = "";
    var that=this;
    this.init=function(){
        that.popupobj = CrmPopup.getPopupObj("last");
        if(that.popupobj){
            that.divid = this.popupobj.divid;
        }else{
            that.divid ='searchInfo';
        }
        that.tableobj=ld('#'+that.divid+' #totalColumnList');//统计字段表格
        that.ColumnsListObj = CustomEchartsSqlColumnFieldShowObj.getColumnsList(that.chart_type);//统计字段显示栏
        that.setHeader();//设置表头
        //判断是否有新增按钮
        that.newButton = that.ColumnsListObj.newButton;
        ld('#'+that.divid+' #addColumnsTotal').remove();
        if(that.newButton=="yes") {
            var addBtn = '<tr id="addColumnsTotal">\n' +
                '<td colspan="6" align="center">\n' +
                '<a data-index="0" tag="addrow">+新增</a>\n' +
                '</td>\n' +
                '</tr>';
            ld(that.tableobj).append(addBtn);
        }
        that.setTableEvent();
    }
    //设置表头
    this.setHeader = function(){
        //渲染表头
        var thead_tr = '<tr>';
        var fieldHeader = that.ColumnsListObj.field;
        ld.each(fieldHeader,function(index,item){
            var align = 'center';
            if(item.type=='action'){
                align = 'left';
            }
            if(item.type=='sequence'){
                align = 'right';
            }
            thead_tr += ' <td class="DetailedTd1Label" width="'+item.width+'" align="'+align+'">'+item.label+'</td>'
        });
        thead_tr += '</tr>';
        ld('#'+that.divid+' #columnHeader').html(thead_tr);
    }
    //删除所有行
    this.removeAllRow=function(){
        ld(this.tableobj).find(" [tag=trTotalColumnList]").remove();
    }
    //设置事件
    this.setTableEvent=function()
    {
        ld(this.tableobj).find(" [tag=delete]").unbind("click").bind("click",function(){
            var trobj=Tools.getParentobjByChild(ld(this),'tr');
            var rowindex=ld(trobj).attr("rowindex");
            that.removerow(rowindex);
        })
        ld(this.tableobj).find("[tag=addrow]").unbind("click").bind("click",function(){
            that.addrow(null);
        })
    }
    //添加一行统计字段
    this.addrow=function(datavalue)
    {
        //添加行
        var rowindex=parseInt(ld(this.tableobj).find(" [tag=trTotalColumnList]").length)+1;
        var oneLine = '<tr tag="trTotalColumnList" rowindex="'+rowindex+'" >\n';
        var fieldHeader = that.ColumnsListObj.field;
        ld.each(fieldHeader,function(i,it){
            //sequence,field,picklist,text,action
            var style="";
            if(it.inputwidth){
                style = 'style="width:'+it.inputwidth+';"';
            }
            var type = it.type;

            if(type == "sequence"){
                oneLine += '<td class="DetailedTd1Label" tag="rowindex" align="right"><div>#'+rowindex+'</div></td>';
            }
            if(type == "field"){
                oneLine += '<td>' +
                    '<select '+style+' tag="'+it.name+'" rowindex="'+rowindex+'" class="custom-select detailedViewTextBox" name="'+it.name+'[]">'+that.sqlColumnsOptions+'</select>' +
                    '</td>';
            }
            if(type == "picklist"){
                var options = it.options;
                oneLine += '<td>' +
                    '<select '+style+' tag="'+it.name+'" class="custom-select detailedViewTextBox" name="'+it.name+'[]">';
                ld.each(options,function(idx,itm){
                    oneLine += '<option value="'+itm.value+'">'+itm.label+'</option>';
                });
                oneLine += '</select></td>';
            }
            if(type == "text"){
                oneLine += '<td><input '+style+' tag="'+it.name+'" type="text" name="'+it.name+'[]" class="detailedViewTextBox"/></td>';
            }
            if(type == "action"){
                var options = it.options;
                oneLine += '<td class="DetailedTd1Label">';
                ld.each(options,function(idx,itm){
                    oneLine += '<a tag="'+itm.value+'">' +itm.label+'</a>';
                });
                oneLine += '</td>';
            }
        });
        oneLine += '</tr>';
        if(that.newButton=="yes") {

            ld('#'+that.divid+' #addColumnsTotal').before(oneLine);
        }else{
            ld('#'+that.divid+' #columnList').append(oneLine);
        }
        that.setTableEvent();
        var trobj=ld(this.tableobj).find("tr[rowindex="+rowindex+"]");
        var modulejqueryobj = ld(this.tableobj).find("tr[rowindex="+rowindex+"]").find('[tag="column_module"]');
        if(datavalue!=null&&datavalue!=undefined)
        {
            ld.each(fieldHeader,function(i,it){
                var type = it.type;
                var name =it.name;
                var value = datavalue[name];
                that.value_field = value;
                if(type == "field"){
                    ld(trobj).find('[tag="columns"]').find('option[value="'+value+'"]').attr('selected', true);
                }
                if(type == "picklist"){

                    if(that.chart_type=='simple_strip'||that.chart_type=='multiple_strip'||that.chart_type=='stack_strip'){
                        if(name=="yaxisindex"){
                            value = value==0?'bottom':'top';
                        }
                    }else{
                        if(name=="yaxisindex"){
                            value = value==0?'left':'right';
                        }
                    }
                    ld(trobj).find('[tag="'+name+'"]').find('option[value="'+value+'"]').attr('selected', true);
                }
                if(type == "text"){
                    ld(trobj).find('[tag="'+name+'"]').val(value);
                }
            });
        }
    }
    this.removerow=function(rowindex)
    {
        //删除行
        ld(this.tableobj).find("tr[rowindex='"+rowindex+"']").remove();
        that.resetRowindex();
        that.setTableEvent();
    }
    //重设索引
    this.resetRowindex=function(){
        var trobjs=ld(this.tableobj).find("tr[tag='trTotalColumnList']");
        ld.each(trobjs,function(tmpindex,trobj){
            var rowindex=parseInt(tmpindex)+1;
            ld(trobj).attr("rowindex",rowindex);
            ld(trobj).find("td[tag='rowindex']").text('#'+rowindex);
        })
    }
}
var CustomEchartsSqlColumnsObj = new CustomEchartsSqlColumns();

