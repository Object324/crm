//统计字段设置
function cls_conditionColumnList()
{
    this.tableobj=ld("#conditionColumnList");
    this.chart_type='line';
    this.popupobj= "";
    this.divid= "";
    var that=this;
    //wyt 220817 XUQIU1000504 自定义统计图表或报表的查看界面增加快捷编辑按钮
    this.init=function(createObj){
        that.popupobj = createObj.popupobj;
        that.divid = createObj.divid;
        that.CustomEchartsCreateObj = createObj;

        that.tableobj=ld('#'+that.divid+' #conditionColumnList');
        that.setTableEvent();
    }
    this.removeAllRow=function(){
        ld('#'+that.divid).find("[tag=trConditionColumnList]").remove();//删除所有条件行
        ld('#'+that.divid).find("[tag=group]").remove();//组合条件
        ld('#'+that.divid).find("[tag=addColumnsCondition]").remove();//新条件按钮
    }
    this.setTableEvent=function()
    {

        ld(that.tableobj).find("[tag=addrow]").unbind("click").bind("click",function(){
            // var prevtr = ld('#addColumnsCondition').prev();
            // var groupid = prevtr.attr('groupid');
            var trobj=Tools.getParentobjByChild(ld(this),'tr');
            var groupid = trobj.attr('groupid');
            that.addrow({'groupid':groupid,type:'newcolumns'},groupid,trobj);
        });
        ld(that.tableobj).find(" [tag=cvadvfilter]").unbind("change").bind("change",function(){
            that.cvadvfilterChange(ld(this));

        })
        ld(that.tableobj).find(" [tag='comparator']").unbind('change').bind("change",function(){
            that.comparatorChange(ld(this));
        });
        ld(that.tableobj).find("[tag=delete]").unbind("click").bind("click",function(){
            var trobj=Tools.getParentobjByChild(ld(this),'tr');
            var rowindex=ld(trobj).attr("rowindex");
            var groupid=ld(trobj).attr("groupid");
            if(ld('#'+that.divid).find('[tag=trConditionColumnList][groupid='+groupid+']').length<=1){
                //删除行条件时 只有一条的时候 需要把组条件也删除
                if(rowindex==1){
                    ld(trobj).next().remove();//删除下一组的新条件
                    ld(trobj).next().remove();//删除下一组的条件行
                }else{
                    ld(trobj).prev().remove();//删除上一组的条件行
                    ld(trobj).next().remove();//删除下一组的新条件
                }
                that.removegroup(groupid);
            }else{
                that.removerow(rowindex);
            }
        })

        // ld('#'+that.divid).find("[tag=addrow]").unbind("click").bind("click",function(){
        //     var trobj=Tools.getParentobjByChild(ld(this),'tr');
        //     var prevtr = ld(trobj).prev();
        //     var groupid = prevtr.attr('groupid');
        //     that.addrow({'groupid':groupid,type:'newcolumns'},groupid,trobj);
        //
        // })

        //删除组条件
        ld(that.tableobj).find(" [tag=groupdelete]").unbind("click").bind("click",function(){
            var trobj=Tools.getParentobjByChild(ld(this),'tr');
            var groupid=ld(trobj).attr("groupid");
            that.removegroup(groupid);
        });

    }
    this.addrow=function(datavalue,groupid,addobj)
    {
        var linetype = datavalue.type;
        if(linetype=='columns'||linetype=='newcolumns') {
            //搜索查询条件拼接
            var searchFieldRes = that.CustomEchartsCreateObj.searchFieldRes;//所有的字段
            var searchFieldOptions = '';
            ld.each(searchFieldRes, function (idx, itm) {
                searchFieldOptions += itm;
            });
            //添加行
            var rowindex = parseInt(ld(that.tableobj).find(" [tag=trConditionColumnList]").length) + 1
            var comparator = that.getComparator('common', groupid,rowindex);
            var conditionLine = '<tr groupid="' + groupid + '" tag="trConditionColumnList" rowindex="' + rowindex + '">' +
                '<td></td>' +
                '<td scope="row">\n' +
                '<select tag="cvadvfilter" class="custom-select detailedViewTextBox"  name="cvadvfilter[' + groupid + '][' + rowindex + ']">\n' + searchFieldOptions +
                '</select>\n' +
                '</td>\n' +
                '<td>\n' +
                comparator +
                '</td>\n' +
                '<td tag="value-tr">\n' +
                '<input tag="value" type="text"  autocomplete="off" class="detailedViewTextBox" name="value[' + groupid + '][' + rowindex + ']" value="" style="width:95%;">\n' +
                '</td>\n' +
                '<td>\n' +
                '<select tag="columncondition" class="custom-select detailedViewTextBox" name="columncondition[' + groupid + '][' + rowindex + ']">\n' +
                '<option value="and">且</option>\n' +
                '<option value="or">或</option>\n' +
                '</select>\n' +
                '</td>\n' +
                '<td align="left">\n' +
                '<a href="javascript:;" tag="delete">删除</a>' +
                '</td>\n' +
                '</tr>';
            if(linetype=='newcolumns'){
                ld(addobj).before(conditionLine);
            }else{
                ld('#'+that.divid+' #highSearch').append(conditionLine);
            }

            var trobj = ld(that.tableobj).find("tr[rowindex=" + rowindex + "]");

            if (datavalue != null && datavalue != undefined&&!empty(datavalue.columns)) {
                ld(trobj).find('[tag=cvadvfilter]').val(datavalue.columns);
                var bigtype = ld(trobj).find('[tag=cvadvfilter]').find('option[value="' + datavalue.columns + '"]').attr('data-type');
                var comparator = that.getComparator(bigtype);
                ld(trobj).find('[tag=comparator]').html(comparator);
                ld(trobj).find('[tag=comparator]').val(datavalue.comparator);
                ld(trobj).find('[tag=columncondition]').val(datavalue.columncondition);
                var value = datavalue.value;
                that.getValueInput(trobj, bigtype, groupid, datavalue.comparator, value);
                if (datavalue.yaxisindex > -1) {
                    ld(trobj).find('[tag=yaxisList]').val(datavalue.yaxisindex);
                }

            }
            var tmpobj = ld(trobj).find('[tag=cvadvfilter]');
            if(tmpobj.length>0&&frommobile != 'yes'){
                var cls_resetComboxHtmlobj = new cls_resetComboxHtml(tmpobj.attr('name'));
                cls_resetComboxHtmlobj.setPopupObj(that.popupobj);
                cls_resetComboxHtmlobj.setSearchComboxWidthByhtml(tmpobj, 200);
            }
           /* var popupobj = CrmPopup.getPopupObj("last");
            var divid = popupobj.divid;*/
            // ld(trobj).find('[tag=selectfields]').select2({
            //     dropdownParent: ld('#' + that.divid)
            // });
        }else if(linetype=='groups'&&datavalue.groupid>1){
            var addBtn = '<tr tag="addColumnsCondition" groupid="'+(datavalue.groupid-1)+'">\n' +
                '</td><td><td align="left">\n' +
                '<a data-index="0" tag="addrow">'+arrJsPopLabel['NEW2']+'</a>\n' +
                '</td></td><td></td><td></td><td></td><td></td>\n' +
                '</tr>';
            ld('#'+that.divid+' #highSearch').append(addBtn);

            var andselect = datavalue.group_condition=='and'?'selected':'';
            var orselect = datavalue.group_condition=='or'?'selected':'';
            var select = '<tr tag="group" groupid="'+datavalue.groupid+'" >\n' +
                '<td colspan="5">' +
                '<div style="display: flex;justify-content: center">' +
                '<input type="hidden" name="groupid['+datavalue.groupid+']" value="'+datavalue.groupid+'">'+
                '<select style="width:50px;" class="custom-select detailedViewTextBox" id="" name="group_condition['+datavalue.groupid+']">\n' +
                '<option value="and" '+andselect+'>且</option>\n' +
                '<option value="or" '+orselect+'>或</option>\n' +
                '</select></div></td><td><a class="icon-homeimg icon-close" href="javascript:;" title="'+arrJsPopLabel['DELETECOMBINATION'] +'" tag="groupdelete"></a></td></tr>';
            ld('#'+that.divid+' #addNewConditionGroup').attr('data-groupid',datavalue.groupid);
            ld('#'+that.divid+' #highSearch').append(select);
        }else if(linetype=='emptyline'){
            //最后个新条件的按钮
            var addBtn = '<tr tag="addColumnsCondition" groupid="'+groupid+'">\n' +
                '<td></td><td align="left">\n' +
                '<a data-index="0" tag="addrow">'+arrJsPopLabel['NEW2']+'  </a>\n' +
                '</td></td><td></td><td></td><td></td><td></td>\n' +
                '</tr>';
            ld('#'+that.divid+' #highSearch').append(addBtn);
        }
        if(linetype!='emptyline'){
            ld('#'+that.divid).find('[tag=addgroupcondition]').attr('data-groupid',datavalue.groupid);
        }
        that.resetRowindex();
        that.setTableEvent();
    }
    this.removerow=function(rowindex)
    {
        //删除行
        ld(that.tableobj).find("tr[rowindex='"+rowindex+"']").remove();
        that.resetRowindex();
        that.setTableEvent();
    }
    this.removegroup=function(groupid)
    {
        //删除组
        ld('#'+that.divid).find("#conditionColumnList tr[groupid='"+groupid+"']").remove();
        that.resetRowindex();
        that.resetGroupid();
        that.setTableEvent();
    }
    this.removegrouptr=function(groupid)
    {
        //删除行
        var grouptr = ld(that.tableobj).find("tr[tag='group']");
        ld.each(grouptr,function(){
            var groupidthis = ld(that).attr('groupid');
            if(groupidthis==groupid){
                ld(this).remove();
            }
            that.resetRowindex();
            that.setTableEvent();
        });
    }
    this.resetRowindex=function(){
        //tag="trTotalColumnList"
        var trobjs=ld(that.tableobj).find("tr[tag='trConditionColumnList']");
        ld.each(trobjs,function(tmpindex,trobj){
            var rowindex=parseInt(tmpindex)+1;
            ld(trobj).attr("rowindex",rowindex);
        });
    }
    this.resetGroupid=function(curgroupid){
        var trobjs=ld(that.tableobj).find("tr[tag='trConditionColumnList']");
        ld.each(trobjs,function(tmpindex,trobj){
            var groupid = ld(trobj).attr('groupid');
            if(groupid>curgroupid){
                groupid=parseInt(groupid);
                ld(trobj).attr("groupid",groupid);
                ld(trobj).find("input[tag='groupid']").value(groupid);
            }
        });
    }
    //条件字段更改
    this.cvadvfilterChange = function(jqueryobj){
        var value = ld(jqueryobj).val();
        var bigtype = ld(jqueryobj).find('option[value="'+value+'"]').attr('data-type');
        var comparator = that.getComparator(bigtype);
        var trobj = Tools.getParentobjByChild(jqueryobj,'tr');
        ld(trobj).find('[tag=comparator]').html(comparator);
        //BUG0053240	已分派	zxm 客户自定义统计图表时间字段显示不正常（默认区间），需要重新选择一次才选择正常
        var comparatorValue = ld(trobj).find('[tag=comparator]').val();
        var groupid = ld(trobj).attr('groupid');
        that.getValueInput(trobj,bigtype,groupid,comparatorValue,null);
    }
    this.comparatorChange = function(jqueryobj){
        var comparatorValue = ld(jqueryobj).val();
        var trobj = Tools.getParentobjByChild(jqueryobj,'tr');
        var groupid = ld(trobj).attr('groupid');
        var cvadvfilterValue = ld(trobj).find('[tag=cvadvfilter]').val();
        var bigtype = ld(trobj).find('option[value="'+cvadvfilterValue+'"]').attr('data-type');
        that.getValueInput(trobj,bigtype,groupid,comparatorValue,null);
        // alert(comparatorValue)

    }

    this.getValueInput = function(trobj,field_type,groupid,comparatorValue,value){
        let clicktime = '';
        let starttime = '';
        let endtime = '';
        var rowindex = trobj.attr('rowindex');
        let condition_value = timeValueArr[comparatorValue];
        //bw 时间区间的时候  时间显示的总是当天的时间 zxm2022-0627
        if(value&&comparatorValue=='bw'){
            condition_value = value.split(',');
        }
        if(field_type == "time"||field_type == "date") {
            starttime = condition_value[0].split(' ');
            endtime = condition_value[1].split(' ');
        }else if(field_type == "datetime"){
            starttime = condition_value[0];
            endtime = condition_value[1];
        }
        let isreadonly = '';
        if(field_type == "time"){
            starttime = starttime[1];
            endtime = endtime[1];
            clicktime = 'WdatePicker({startDate:\'%H:%M:%S\',dateFmt:\'HH:mm:ss\',alwaysUseStartDate:true})';
        }else if(field_type == "date"){
            starttime = starttime[0];
            endtime = endtime[0];
            clicktime = 'WdatePicker({startDate:\'%y-%M-%d\',dateFmt:\'yyyy-MM-dd\',alwaysUseStartDate:true})';
        }else if(field_type == "datetime"){
            clicktime = 'WdatePicker({startDate:\'%y-%M-%d %H:%M:%S\',dateFmt:\'yyyy-MM-dd HH:mm:ss\',alwaysUseStartDate:true})';
        }else{
            clicktime = '';
            starttime = '';
        }
        var valueObj = ld(trobj).find('[tag=value-tr]');
        if(comparatorValue!='e'&&comparatorValue!='n'&&comparatorValue!='l'&&comparatorValue!='g'&&comparatorValue!='m'&&comparatorValue!='h'&&comparatorValue!='k'&&comparatorValue!='c'){
            if(field_type == "time"||field_type == "date"||field_type == "datetime"){
                isreadonly = 'readonly';
            }
            else if(comparatorValue=='bw'){
                isreadonly = '';
            }
            var html_str = '';
            if(endtime){
                html_str += '<div class="flex-input-group">';
            }
            html_str += '<input style="width:95%;" '+isreadonly+' type="text" class="detailedViewTextBox" name="value['+groupid+']['+rowindex+']" autocomplete="off" value="'+starttime+'" onclick="'+clicktime+'">';
            if(endtime){
                html_str+='</div><div class="flex-input-group"><input '+isreadonly+' type="text" class="detailedViewTextBox" autocomplete="off" value="'+endtime+'" name="value2['+groupid+']['+rowindex+']" onclick="'+clicktime+'"></div>';
            }else{
                html_str+='</div><div style="display:none;" class="flex-input-group"><input '+isreadonly+' type="hidden" class="detailedViewTextBox" autocomplete="off" value="" name="value2['+groupid+']['+rowindex+']" onclick=""></div>';
            }
            valueObj.html(html_str);
        }else {
            value = value?value:starttime;
            isreadonly = '';
            var html_str = '<input style="width:95%;" '+isreadonly+' type="text" class="detailedViewTextBox" name="value['+groupid+']['+rowindex+']" autocomplete="off" value="'+value+'" onclick="'+clicktime+'">';
            html_str+='<input  type="hidden" class="detailedViewTextBox" name="value2['+groupid+']['+rowindex+']" autocomplete="off" >';
            valueObj.html(html_str);
        }
    }
    this.getComparator = function(type,groupid,rowindex) {
        var arr = {};
        //选择条件
        if(type=='datetime'||type=='date'||type=='time'){
            arr = {
                bw: '区间',
                e: '等于',
                n: '不等于',
                l:'小于',
                g:'大于',
                m:'小于等于',
                h:'大于等于',
                isnull: '为空值',
                isnotnull: '不为空值',
                prevfy:'去年',
                thisfy:'本年',
                nextfy:'明年',
                prevfq:'上季度',
                thisfq:'本季度',
                nextfq:'下季度',
                syesterday:'昨天',
                today:'今天',
                tomorrow:'明天',
                lastweek:'上周',
                thisweek:'本周',
                nextweek:'下周',
                lastmonth:'上月',
                thismonth:'本月',
                nextmonth:'下月',
                //wyt 220819 XUQIU1000506 自定义报表或图表的日期条件优化
                before1days:'1天前',
                before2days:'2天前',
                before3days:'3天前',
                before4days:'4天前',
                before5days:'5天前',
                before6days:'6天前',
                before7days:'7天前',
                before8days:'8天前',
                before9days:'9天前',
                before10days:'10天前',
                before11days:'11天前',
                before12days:'12天前',
                before13days:'13天前',
                before14days:'14天前',
                before15days:'15天前',
                before30days:'30天前',
                before60days:'60天前',
                before90days:'90天前',
                before120days:'120天前',
                before180days:'180天前',
                before365days:'365天前',
                last1days:'过去1天',
                last2days:'过去2天',
                last3days:'过去3天',
                last4days:'过去4天',
                last5days:'过去5天',
                last6days:'过去6天',
                last7days:'过去7天',
                last8days:'过去8天',
                last9days:'过去9天',
                last10days:'过去10天',
                last11days:'过去11天',
                last12days:'过去12天',
                last13days:'过去13天',
                last14days:'过去14天',
                last15days:'过去15天',
                last30days:'过去30天',
                last60days:'过去60天',
                last90days:'过去90天',
                last120days:'过去120天',
                last180days :'过去180天',
                last365days:'过去365天',
                next1days:'未来1天',
                next2days:'未来2天',
                next3days:'未来3天',
                next4days:'未来4天',
                next5days:'未来5天',
                next6days:'未来6天',
                next7days:'未来7天',
                next8days:'未来8天',
                next9days:'未来9天',
                next10days:'未来10天',
                next11days:'未来11天',
                next12days:'未来12天',
                next13days:'未来13天',
                next14days:'未来14天',
                next15days:'未来15天',
                next30days:'未来30天',
                next60days:'未来60天',
                next90days:'未来90天',
                next120days:'未来120天',
                next180days :'未来180天',
                next365days:'未来365天',
                after1days:'1天后',
                after2days:'2天后',
                after3days:'3天后',
                after4days:'4天后',
                after5days:'5天后',
                after6days:'6天后',
                after7days:'7天后',
                after8days:'8天后',
                after9days:'9天后',
                after10days:'10天后',
                after11days:'11天后',
                after12days:'12天后',
                after13days:'13天后',
                after14days:'14天后',
                after15days:'15天后',
                after30days:'30天后',
                after60days:'60天后',
                after90days:'90天后',
                after120days:'120天后',
                after180days:'180天后',
                after365days:'365天后',

        };
        }
        else if(type=='number'||type=='currency')
        {
            arr = {
              
                e: '等于',
                n: '不等于',
                l:'小于',
                g:'大于',
                m:'小于等于',
                h:'大于等于'};
        }
        else{
            arr = {
                c: '包含',
                e: '等于',
                n: '不等于',
                k: '不包含',
                isnull: '为空',
                isnotnull: '不为空',
            };
        }
        var condtionComparatorSelect = '<select tag="comparator" class="custom-select detailedViewTextBox default-class" name="comparator['+groupid+']['+rowindex+']">';
        ld.each(arr,function(idx,itm){
            condtionComparatorSelect += '<option value="'+idx+'">'+itm+'</option>\n';
        });
        condtionComparatorSelect += '</select>\n';
        return condtionComparatorSelect;
    }
}
var conditionColumnListTableObj = new cls_conditionColumnList();

