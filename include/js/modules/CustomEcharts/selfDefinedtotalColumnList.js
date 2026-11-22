//统计字段设置
function cls_totalColumnList()
{
    this.tableobj=ld('#totalColumnList');
    this.chart_type='line';
    this.report_id = 0;
    this.ColumnsListObj = {};
    this.newButton = "yes";
    this.popupobj = "";
    this.divid = "searchInfo";
    var that=this;
    this.init=function(createObj){
        that.popupobj = createObj.popupobj;
        that.divid = createObj.divid;
        that.CustomEchartsCreateObj = createObj;
        that.chart_type = createObj.chart_type;
        that.tableobj=ld('#'+that.divid+' #totalColumnList');
        //判断是否有新增按钮
        that.ColumnsListObj = CustomEchartsColumnFieldShowObj.getColumnsList(that.chart_type);
        that.newButton = that.ColumnsListObj.newButton;
        that.setHeader();
        ld('#'+that.divid+' #addColumnsTotal').remove();
        if(that.newButton=="yes") {
            var addBtn = '<tr id="addColumnsTotal">\n' +
                '<td colspan="6" align="center">\n' +
                '<a data-index="0" tag="addrow">+新增</a>\n' +
                '</td>\n' +
                '</tr>';
            ld(that.tableobj).append(addBtn);
        }
    }

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

    this.removeAllRow=function(){
        ld(this.tableobj).find(" [tag=trTotalColumnList]").remove();
    }
    this.setTableEvent=function()
    {
        //选择模块change事件
        ld(that.tableobj).find(" [tag=column_module]").unbind("change").bind("change",function(){
            that.columnModuleChange(this);
        })
        //合计字段change事件
        ld(that.tableobj).find(" [tag=total_type]").unbind("change").bind("change",function(){
            that.total_typeChange(ld(this));
        })
        
        ld(that.tableobj).find(" [tag=delete]").unbind("click").bind("click",function(){
            var trobj=Tools.getParentobjByChild(ld(this),'tr');
            var rowindex=ld(trobj).attr("rowindex");
            that.removerow(rowindex);
        })
        ld(that.tableobj).find("[tag=addrow]").unbind("click").bind("click",function(){
            var rowindex = parseInt(ld(that.tableobj).find(" [tag=trTotalColumnList]").length)+1;
            that.CustomEchartsCreateObj.setFieldRes(rowindex);
            that.addrow(null);
            //字段下拉框初始化
            var column_module_obj = ld(that.tableobj).find("tr[rowindex="+rowindex+"]").find("[tag='column_module']");
            that.CustomEchartsCreateObj.setFieldsByModule(column_module_obj);
        })
    }

    this.addrow=function(datavalue)
    {
        //添加行
        var rowindex=parseInt(ld(that.tableobj).find(" [tag=trTotalColumnList]").length)+1;
        var oneLine = '<tr tag="trTotalColumnList" rowindex="'+rowindex+'" >\n';
        var moduleOptions = that.CustomEchartsCreateObj.relatedModuleOptions;
        var fieldHeader = that.ColumnsListObj.field;
        ld.each(fieldHeader,function(i,it){
            var style="";
            if(it.inputwidth){
                style = 'style="width:'+it.inputwidth+';"';
            }
            var type = it.type;

            if(type == "sequence"){
                oneLine += '<td class="DetailedTd1Label" tag="rowindex" align="right"><div>#'+rowindex+'</div></td>';
            }
            if(type == "module"){
                oneLine += '<td>' +
                    '<select '+style+' tag="'+it.name+'" rowindex="'+rowindex+'" class="custom-select detailedViewTextBox" name="'+it.name+'[]" fieldtype="selecttype">'+moduleOptions+'</select>' +
                    '</td>';
            }
            if(type == "field"){
                var option = '';
                oneLine += '<td>' +
                    '<select '+style+' tag="'+it.name+'" rowindex="'+rowindex+'" class="custom-select detailedViewTextBox" name="'+it.name+'[]" fieldtype="selecttype">'+option+'</select>' +
                    '</td>';
            }
            if(type == "picklist"){
                var options = it.options;
                oneLine += '<td>' +
                    '<select '+style+' tag="'+it.name+'" class="custom-select detailedViewTextBox" name="'+it.name+'[]" fieldtype="selecttype">';
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
                if(type == "module"){
                    if(value==null){
                        var temp_field_vale = datavalue["columns"];
                        temp_field_vale = temp_field_vale.replace('_',":");
                        temp_field_vale = temp_field_vale.split(':');
                        value = temp_field_vale[4];
                        value = value.split('_');
                        value = value[0];
                    }
                    ld(trobj).find('[tag="'+name+'"]').find('option[value="'+value+'"]').attr('selected', true);
                }
                if(type == "field"){
                    that.CustomEchartsCreateObj.setFieldsByModule(modulejqueryobj,function(value){
                        that.changeSelectFields(trobj, value);
                    });
                    setTimeout(function(){
                        ld(trobj).find('[tag="columns"]').find('option[value="'+value+'"]').attr('selected', true);
                    },600);
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
        }else{
            that.CustomEchartsCreateObj.setFieldsByModule(modulejqueryobj,function() {
                that.changeSelectFields(trobj, '');
            });
        }
		//edit: xll BUG0062038 自定义统计图表，“统计图配置”页签，下拉框没有搜索功能
        var selectobj = ld(trobj).find("select[fieldtype=selecttype]");
        setTimeout(function(){
            ld.each(selectobj, function(i,tmpselectobj){
                var tmpobj = ld(tmpselectobj);
                if(tmpobj.length > 0 && tmpobj != undefined){
                    that.resetTrCombox(tmpobj,trobj);
                }
            });
        },600);
    }
    this.removerow=function(rowindex)
    {
        //删除行
        ld(this.tableobj).find("tr[rowindex='"+rowindex+"']").remove();
        that.resetRowindex();
        that.setTableEvent();
    }
    this.changeAllRowSelectField=function(){
        //改变所有行的统计字段的下拉框内容
        var trobjs=ld(this.tableobj).find("tr[tag='trTotalColumnList']");
        ld.each(trobjs,function(tmpindex,trobj){
            that.changeSelectFields(trobj);
        })
    } 
    this.changeSelectFieldValByRowindex=function(val,rowindex){
         var trobj=ld(this.tableobj).find("tr[rowindex='"+rowindex+"']");
       
         var selectfieldobj = ld(trobj).find('[tag="selectfields"]');
         var popupobj=CrmPopup.getPopupObj('last');
         
         selectfieldobj.find('option[value="'+val+'"]').attr('selected', true);
           ld(trobj).find('[tag=selectfields]').select2({
            dropdownParent: ld('#'+popupobj.divid)
        });  
           
    }
    this.total_typeChange=function(jqueryobj){
        //计算方法改变
        var trobj = Tools.getParentobjByChild(jqueryobj,'tr');
        this.changeSelectFields(trobj,'');
		//edit: xll BUG0062038 自定义统计图表，“统计图配置”页签，下拉框没有搜索功能
        var selectobj = ld(trobj).find("[tag=columns]");
        if(selectobj.length > 0 && selectobj != undefined){
            that.resetTrCombox(selectobj,trobj)
        }    }
    //统计字段方法改变
    this.changeSelectFields=function(trobj,value_field){
        var rowindex = trobj.attr('rowindex');
        var sumFieldRes = that.CustomEchartsCreateObj.sumFieldRes[rowindex];//默认值求和类型的字段
        var countFieldRes = that.CustomEchartsCreateObj.countFieldRes[rowindex];
        var sumFieldOptions = '';
        var countFieldOptions = '';
        ld.each(sumFieldRes,function(idx,itm){
            sumFieldOptions += itm;
        });
        ld.each(countFieldRes,function(idx,itm){
            countFieldOptions += itm;
        });
        var value = ld(trobj).find('[tag=total_type]').val();
        //修改统计字段的下拉框内容
        if(value=='count'||value=='distinct_count'){
            ld(trobj).find('[tag=columns]').html(countFieldOptions);
        }else{
            ld(trobj).find('[tag=columns]').html(sumFieldOptions);
        }
        // ld(trobj).find('[tag="columns"]').find('option[value="'+value_field+'"]').attr('selected', true);
    }
    //选择模块改变
    this.columnModuleChange = function(jqueryobj){
        var trobj = Tools.getParentobjByChild(jqueryobj,'tr');
        that.CustomEchartsCreateObj.setFieldsByModule(jqueryobj,function(){
            that.changeSelectFields(trobj,'');
        });
		//edit: xll BUG0062038 自定义统计图表，“统计图配置”页签，下拉框没有搜索功能
        var selectobj = ld(trobj).find("[tag=columns]");
        if(selectobj.length > 0 && selectobj != undefined){
            that.resetTrCombox(selectobj,trobj)
        }    }
    //重设索引
    this.resetRowindex=function(){
        var trobjs=ld(this.tableobj).find("tr[tag='trTotalColumnList']");
        ld.each(trobjs,function(tmpindex,trobj){
            var rowindex=parseInt(tmpindex)+1;
            ld(trobj).attr("rowindex",rowindex);
            ld(trobj).find("td[tag='rowindex']").text('#'+rowindex);
        })
    }
	//重设下拉框为可搜索下拉框
    this.resetTrCombox = function(selectobj,trobj){
        var Popupobj = CrmPopup.getPopupObj('last');
        Popupobj.detailfieldcolumninfo = [];
        ld.each(that.ColumnsListObj.field, function (tmpindex, tmpfieldinfo) {
            Popupobj.detailfieldcolumninfo[tmpfieldinfo.name + '[]'] = tmpfieldinfo;
        })
        var tmptdobj = Tools.getParentobjByChild(selectobj,'td');
        var tmpwidth = parseInt(tmptdobj.css('width'))*0.9;

        var cls_resetComboxHtmlobj = new cls_resetComboxHtml(selectobj.attr("name"));
        cls_resetComboxHtmlobj.trobj = trobj;
        cls_resetComboxHtmlobj.setPopupObj(Popupobj);
        cls_resetComboxHtmlobj.detailrowindex = trobj.attr('rowindex');
        cls_resetComboxHtmlobj.setSearchComboxWidthByhtml(selectobj,tmpwidth);
    }}
var totalColumnListTableObj = new cls_totalColumnList();

