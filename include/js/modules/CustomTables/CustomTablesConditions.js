function CustomTablesConditions(){
    this.comparatorCommon = {
        c: arrJsPopLabel['Include'],
        e: arrJsPopLabel['Equal'],
        n: arrJsPopLabel['NoEqual'],
        k: arrJsPopLabel['NotInclude'],
        isnull: arrJsPopLabel['Empty'],
        isnotnull: arrJsPopLabel['NotNull']
    }
    this.comparatorNumber = {
        e: arrJsPopLabel['Equal'],
        n: arrJsPopLabel['NoEqual'],
        l: arrJsPopLabel['LessThan'],
        g: arrJsPopLabel['MoreThan'],
        m: arrJsPopLabel['LTET'],
        h: arrJsPopLabel['MTET'],
        isnull: arrJsPopLabel['Empty'],
        isnotnull: arrJsPopLabel['NotNull']
    }
    this.comparatorTime = {
        bw: arrJsPopLabel['Interval'] ,
        e: arrJsPopLabel['Equal'],
        n: arrJsPopLabel['NoEqual'],
        l: arrJsPopLabel['LessThan'],
        g: arrJsPopLabel['MoreThan'],
        m: arrJsPopLabel['LTET'],
        h: arrJsPopLabel['MTET'],
        isnull: arrJsPopLabel['Empty'] +'值',
        isnotnull: arrJsPopLabel['NotNull'] +'值',
        prevfy: arrJsPopLabel['LastY'],
        thisfy: arrJsPopLabel['ThisY'],
        nextfy: arrJsPopLabel['NextY'],
        prevfq: arrJsPopLabel['LastQ'],
        thisfq: arrJsPopLabel['ThisQ'],
        nextfq: arrJsPopLabel['NextQ'],
        syesterday: arrJsPopLabel['yesterday'],
        today: arrJsPopLabel['today'],
        tomorrow: arrJsPopLabel['tomorrow'],
        lastweek: arrJsPopLabel['LastWeek'],
        thisweek: arrJsPopLabel['ThisWeek'],
        nextweek: arrJsPopLabel['NextWeek'],
        lastmonth: arrJsPopLabel['LastM'],
        thismonth: arrJsPopLabel['ThisM'],
        nextmonth: arrJsPopLabel['NextM'],
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
        after365days:'365天后'
    }
    this.conditionColumnBodyObj = "";//表体
    this.tableobj=ld("#conditionColumnList");
    this.popupobj = "";
    this.divid = "";
    this.mode = "init";
    this.searchFieldRes = {};
    this.timeValueArr = {};
    this.tableobj;

    var that = this;
    this.init = function(searchFieldRes,timeValueArr,mode){
        that.timeValueArr = timeValueArr;
        that.tableobj=ld('#'+that.divid+' #conditionColumnList');
        if(mode!=undefined){
            that.mode = mode;
        }
        that.searchFieldRes = searchFieldRes;
        that.conditionColumnBodyObj = ld('#'+that.divid+' #conditionColumnBody');
        ld(this.tableobj).find("[tag=addrow]").unbind("click").bind("click",function(){
            var trobj=Tools.getParentobjByChild(ld(this),'tr');
            that.addrow({'groupid':groupid,type:'newcolumns'},trobj);
        });
    }
    this.setPopupobj = function(popupobj){
        that.popupobj = popupobj;
    }
    this.setDivid = function(divid){
        that.divid = divid;
    }
    this.removeAllRow=function(){
        ld(this.tableobj).find("[tag=trConditionColumnList]").remove();
        ld(this.tableobj).find("[tag=group]").remove();//组合条件
        ld(this.tableobj).find("[tag=addColumnsCondition]").remove();//新条件按钮
    }
    this.setTableEvent=function()
    {
        ld(this.tableobj).find(" [tag=clearAll]").unbind("click").bind("click",function(){
            that.removeAllRow();
            ld(that.tableobj).find("[tag=addgroupcondition]").attr('data-groupid',0);
        });
        ld(this.tableobj).find(" [tag=cvadvfilter]").unbind("change").bind("change",function(){
            that.cvadvfilterChange(ld(this));
        });
        ld(this.tableobj).find(" [tag='comparator']").unbind('change').bind("change",function(){
            that.comparatorChange(ld(this));
        });
        //增加行条件
        ld(this.tableobj).find("[tag=addrow]").unbind("click").bind("click",function(){
            var groupid = ld(that.tableobj).find("[tag=addgroupcondition]").attr('data-groupid');//当前groupid
            var trobj=Tools.getParentobjByChild(ld(this),'tr');
            groupid = trobj.prev().attr('groupid')>0?trobj.prev().attr('groupid'):groupid;
            that.addrow({'groupid':groupid,type:'newcolumns'},trobj);
        });
        //删除行条件
        ld(this.tableobj).find(" [tag=delete]").unbind("click").bind("click",function(){
            var trobj=Tools.getParentobjByChild(ld(this),'tr');
            var rowindex=ld(trobj).attr("rowindex");
            var groupid=ld(trobj).attr("groupid");
            if(ld(that.tableobj).find('[tag=trConditionColumnList][groupid='+groupid+']').length<=1){
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
        });

        //增加组条件
        ld(that.tableobj).find("[tag=addgroupcondition]").unbind("click").bind("click",function(){
            that.addgroupcondition(this);
        });
        //删除组条件
        ld(this.tableobj).find(" [tag=groupdelete]").unbind("click").bind("click",function(){
            var trobj=Tools.getParentobjByChild(ld(this),'tr');
            var groupid=ld(trobj).attr("groupid");
            that.removegroup(groupid);
        });
    }
    this.addgroupcondition=function(obj){
        var that = this;
        var curgroupid = ld(obj).attr('data-groupid');
        var nextgroupid = parseInt(curgroupid)+1;
        ld(obj).attr('data-groupid',nextgroupid);
        var conditiontr = ld('#'+that.divid+' #conditionColumnBody').children();


        if(conditiontr.length >=2){
            var select = '<tr tag="group" groupid="'+nextgroupid+'">\n' +
                '<td colspan="4">' +
                '<div style="display: flex;justify-content: center">' +
                '<input type="hidden" name="group_condition_id[]" value="'+nextgroupid+'">'+
                '<select style="width:50px;" class="custom-select detailedViewTextBox" id="" name="group_condition[]">\n' +
                '<option value="and">'+arrJsPopLabel['SEARCHAND']+'</option>\n' +
                '<option value="or">'+arrJsPopLabel['OR']+'</option>\n' +
                '</select></div></td><td><a class="icon-homeimg icon-close" href="javascript:;" title="'+arrJsPopLabel['DELETECOMBINATION'] +'" tag="groupdelete"></a></td></tr>';
            ld('#'+that.divid+' #conditionColumnBody').append(select);
        }
        that.addrow({'groupid':nextgroupid,type:'columns'},null);
        //新条件按钮
        var addBtn = '<tr tag="addColumnsCondition" groupid="'+nextgroupid+'">\n' +
            '<td colspan="6" align="left">\n' +
            '<a data-index="0" tag="addrow">'+arrJsPopLabel['NEW2']+'  </a>\n' +
            '</td>\n' +
            '</tr>';
        ld('#'+that.divid+' #conditionColumnBody').append(addBtn);
        that.resetRowindex();
        //增加行条件
        ld(this.tableobj).find("[tag=addrow]").unbind("click").bind("click",function(){
            var groupid = ld(that.tableobj).find("[tag=addgroupcondition]").attr('data-groupid');//当前groupid
            var trobj=Tools.getParentobjByChild(ld(this),'tr');
            groupid = trobj.prev().attr('groupid')>0?trobj.prev().attr('groupid'):groupid;
            that.addrow({'groupid':groupid,type:'newcolumns'},trobj);
        });
        // that.setTableEvent();
    }
    this.addrow=function(datavalue,addobj) {
        var linetype=datavalue.type;
        if(linetype=='columns'||linetype=='newcolumns') {
            //搜索查询条件拼接
            var searchFieldRes = that.searchFieldRes;//所有的字段
            var searchFieldOptions = '';
            // <optgroup label="标签" class="select" style="border:none"><option value="ld_account:tag:tag:Accounts_标签:V" selected="">标签</option></optgroup>
            ld.each(searchFieldRes, function (idx, itm) {
                searchFieldOptions += '<optgroup label="' + itm.label + '" class="select" style="border:none">';
                ld.each(itm.child, function (i, val) {
                    searchFieldOptions += '<option data-type="' + val.bigtype + '" value="' + val.value + '">' + val.label + '</option>';
                });
                searchFieldOptions += '</optgroup>';
            });
            //添加行--条件
            var rowindex = parseInt(ld(this.tableobj).find(" [tag=trConditionColumnList]").length) + 1;
            var comparator = that.getComparator("");
            var conditionLine = '<tr tag="trConditionColumnList" rowindex="' + rowindex + '"  groupid="' + datavalue.groupid + '">' +
                '<td scope="row">\n' +
                '<div  style="float:left;width:90%;"><select tag="cvadvfilter" class="custom-select detailedViewTextBox"  name="cvadvfilter[]">\n' + searchFieldOptions +
                '<input tag="groupid" type="hidden"  autocomplete="off" class="detailedViewTextBox" name="groupid[]" value="' + datavalue.groupid + '">' +
                '</select>\n' +
                '</td>\n' +
                '<td>\n' +
                comparator +
                '</td>\n' +
                '<td tag="value-tr">\n' +
                '<input tag="value" type="text"  autocomplete="off" class="detailedViewTextBox" name="value1[]" value=""> <input tag="value" type="hidden"  autocomplete="off" class="detailedViewTextBox" name="value2[]" value="">\n' +
                '</td>\n' +
                '<td>\n' +
                '<select tag="columncondition" class="custom-select detailedViewTextBox" name="columncondition[]">\n' +
                '<option value="and">' + arrJsPopLabel['SEARCHAND'] + '</option>\n' +
                '<option value="or">' + arrJsPopLabel['OR'] + '</option>\n' +
                '</select>\n' +
                '</td>\n' +
                '<td align="center">\n' +
                '<a href="javascript:;" tag="delete">' + arrJsPopLabel['DELETE'] + '</a>' +
                '</td>\n' +
                '</tr>';
            if(linetype=='newcolumns'){
                ld(addobj).before(conditionLine);
            }else{
                ld('#'+that.divid+' #conditionColumnBody').append(conditionLine);
            }

            var trobj = ld(this.tableobj).find("tr[rowindex=" + rowindex + "]");
            if(trobj.length > 0){
                if (datavalue != null && datavalue != undefined&&!empty(datavalue.columns)) {
                    ld(trobj).find('[tag=cvadvfilter]').val(datavalue.columns);
                    var bigtype = ld(trobj).find('[tag=cvadvfilter]').find('option[value="' + datavalue.columns + '"]').attr('data-type');
                    var comparator = that.getComparator(bigtype);
                    ld(trobj).find('[tag=comparator]').parent().html(comparator);
                    ld(trobj).find('[tag=comparator]').val(datavalue.comparator);
                    ld(trobj).find('[tag=columncondition]').val(datavalue.columncondition);
                    var value = datavalue.value;
                    that.getValueInput(trobj, bigtype, datavalue.comparator, value);
                }else{

                    that.cvadvfilterChange(ld(trobj).find('[tag=cvadvfilter]'));
                }
            }


            var divid = that.divid;
            /**ld(trobj).find('[tag=selectfields]').select2({
                dropdownParent: ld('#' + divid)
            });*/
        }else if(linetype=='groups'&&datavalue.groupid>=2){
            var addBtn = '<tr tag="addColumnsCondition" groupid="'+(datavalue.groupid-1) +'">\n' +
                '<td colspan="6" align="left">\n' +
                '<a data-index="0" tag="addrow">'+arrJsPopLabel['NEW2']+'  </a>\n' +
                '</td>\n' +
                '</tr>';
            ld('#'+that.divid+' #conditionColumnBody').append(addBtn);
            //渲染组条件
            var andselect = datavalue.group_condition=='and'?'selected':'';
            var orselect = datavalue.group_condition=='or'?'selected':'';
            var select = '<tr tag="group" groupid="'+datavalue.groupid+'">\n' +
                '<td colspan="4">' +
                '<div style="display: flex;justify-content: center">' +
                '<input type="hidden" name="group_condition_id[]" value="'+datavalue.groupid+'">'+
                '<select style="width:50px;" class="custom-select detailedViewTextBox" id="" name="group_condition[]">\n' +
                '<option value="and" '+andselect+'>'+arrJsPopLabel['SEARCHAND']+'</option>\n' +
                '<option value="or" '+orselect+'>'+arrJsPopLabel['OR']+'</option>\n' +
                '</select></div></td><td><a class="icon-homeimg icon-close" href="javascript:;" title="'+arrJsPopLabel['DELETECOMBINATION'] +'" tag="groupdelete"></a></td></tr>';
            ld('#'+that.divid+' #conditionColumnBody').append(select);
        }else if(linetype=='emptyline'){
            //最后个新条件的按钮
            var groupid = ld(that.tableobj).find("[tag=addgroupcondition]").attr('data-groupid');//当前groupid
            if(groupid>0){
                var addBtn = '<tr tag="addColumnsCondition" groupid="'+groupid+'">\n' +
                    '<td colspan="6" align="left">\n' +
                    '<a data-index="0" tag="addrow">'+arrJsPopLabel['NEW2']+'  </a>\n' +
                    '</td>\n' +
                    '</tr>';
                ld(that.tableobj).append(addBtn);
            }
        }
        if(linetype!='emptyline'){
            var tmpgroupid = datavalue.groupid<=0?1:datavalue.groupid;
            ld('#'+that.divid).find('[tag=addgroupcondition]').attr('data-groupid',tmpgroupid);
        }
        //wyt 220830 XUQIU1000509 自定义统计表选择模块字段增加模糊搜索
        that.resetRowindex();
        that.setTableEvent();
        that.fieldfuzzysearch('cvadvfilter',that.divid);
    }
    this.removerow=function(rowindex)
    {
        var groupid = ld(this.tableobj).find("tr[rowindex='"+rowindex+"']").attr('groupid');
        if(ld(this.tableobj).find("tr[groupid='"+groupid+"']").length<=1){
            this.removegroup(groupid);
            that.resetGroupid();
        }else{
            //删除行
            ld(this.tableobj).find("tr[rowindex='"+rowindex+"']").remove();
        }
        that.resetRowindex();
        this.setTableEvent();
    }
    this.removegroup=function(groupid)
    {
        //删除组
        ld(this.tableobj).find("tr[groupid='"+groupid+"']").remove();
        that.resetRowindex();
        that.resetGroupid();
        this.setTableEvent();
    }
    this.resetRowindex=function(){
        var trobjs=ld(this.tableobj).find("tr[tag='trConditionColumnList']");
        ld.each(trobjs,function(tmpindex,trobj){
            var rowindex=parseInt(tmpindex)+1;
            ld(trobj).attr("rowindex",rowindex);
        });
    }
    this.resetGroupid=function(curgroupid){
        var trobjs=ld(this.tableobj).find("tr[tag='trConditionColumnList']");
        ld.each(trobjs,function(tmpindex,trobj){
            var groupid = ld(trobj).attr('groupid');
            if(groupid>curgroupid){
                groupid=parseInt(groupid)+1;
                ld(trobj).attr("groupid",groupid);
                ld(trobj).find("input[tag='groupid']").value(groupid);
            }
        });
    }
    //条件字段更改
    this.cvadvfilterChange = function(jqueryobj){
        var value = ld(jqueryobj).val();
        var bigtype = ld(jqueryobj).find('option[value="'+value+'"]').attr('data-type');
        var comparator =  this.getComparator(bigtype);
        var trobj = Tools.getParentobjByChild(jqueryobj,'tr');
        ld(trobj).find('[tag=comparator]').parent().html(comparator);
        //BUG0053240	已分派	zxm 客户自定义统计图表时间字段显示不正常（默认区间），需要重新选择一次才选择正常
        var comparatorValue = ld(trobj).find('[tag=comparator]').val();
        that.getValueInput(trobj,bigtype,comparatorValue,null);
    }
    this.comparatorChange = function(jqueryobj){
        var comparatorValue = ld(jqueryobj).val();
        var trobj = Tools.getParentobjByChild(jqueryobj,'tr');
        var cvadvfilterValue = ld(trobj).find('[tag=cvadvfilter]').val();
        var bigtype = ld(trobj).find('option[value="'+cvadvfilterValue+'"]').attr('data-type');
        that.getValueInput(trobj,bigtype,comparatorValue,null);
    }
    this.getValueInput = function(trobj,field_type,comparatorValue,value){
        var clicktime = '';
        var starttime = '';
        var endtime = '';
        var condition_value = that.timeValueArr[comparatorValue];
        //bw 时间区间的时候  时间显示的总是当天的时间 zxm2022-0627
        if(value&&comparatorValue=='bw'){
            condition_value = value.split(',');
        }
        if((field_type == "time"||field_type == "date")&&condition_value) {
            starttime = condition_value[0].split(' ');
            endtime = condition_value[1].split(' ');
        }else if(field_type == "datetime"&&condition_value){
            starttime = condition_value[0];
            endtime = condition_value[1];
        }
        //BUG0075002   报表分析->新建自定义模块报表（服务收费管理->服务合同），高级设置中默认设置了一个查询条件
        if(!value&&comparatorValue=='bw'){
            starttime = ' ';
            endtime = ' ';
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
            html_str += '<input '+isreadonly+' type="text" class="detailedViewTextBox" name="value1[]" autocomplete="off" value="'+starttime+'" onclick="'+clicktime+'">';
            if(endtime){
                html_str+='</div><div class="flex-input-group"><input '+isreadonly+' type="text" class="detailedViewTextBox" autocomplete="off" value="'+endtime+'" name="value2[]" onclick="'+clicktime+'"></div>';
            }else{
                html_str+='</div><div style="display:none;" class="flex-input-group"><input '+isreadonly+' type="hidden" class="detailedViewTextBox" autocomplete="off" value="" name="value2[]" onclick=""></div>';
            }
            valueObj.html(html_str);
        }else {
            value = value?value:starttime;
            isreadonly = '';
            var html_str = '<input '+isreadonly+' type="text" class="detailedViewTextBox" name="value1[]" autocomplete="off" value="'+value+'" onclick="'+clicktime+'">';
            html_str+='<input  type="hidden" class="detailedViewTextBox" name="value2[]" autocomplete="off" >';
            valueObj.html(html_str);
        }
    }
    this.getComparator = function(bigtype) {
        var comparator = that.comparatorCommon;
        if(bigtype=='datetime'||bigtype=='date'||bigtype=='time'){
            comparator = that.comparatorTime;
        }else if(bigtype=='number'||bigtype=='currency'||bigtype=='num'){
            comparator = that.comparatorNumber;
        }
        var condtionComparatorSelect = '<select tag="comparator" class="custom-select detailedViewTextBox default-class" name="comparator[]">';
        ld.each(comparator,function(idx,itm){
            condtionComparatorSelect += '<option value="'+idx+'">'+itm+'</option>\n';
        });
        condtionComparatorSelect += '</select>\n';
        return condtionComparatorSelect;
    }
    //wyt 220830 XUQIU1000509 自定义统计表选择模块字段增加模糊搜索
    this.fieldfuzzysearch=function(tagname,divid){
        var objs=ld('#' + divid).find('[tag='+tagname+']');
        ld.each(objs,function (i,obj) {
            ld(obj).select2({width:'100%',closeOnSelect: true});
        })
    }
}
