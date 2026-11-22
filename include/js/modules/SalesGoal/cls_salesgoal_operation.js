function cls_salesgoal_operation(){
    var that = this;
    this.popupobj = '';
    this.targetid = 0;
    this.cur_rowindex = 0;
    //詳情需要使用的字段信息
    this.entitytype_arr = [];
    this.mainfield_arr = [];
    this.detailfield_arr = [];
    this.funname_arr = [];
    this.approvedemand_arr = [];
    this.label_arr = [];
    this.divid = '';

    this.selectClass = "ld-form-item-content-entry ld-select-inner gwidth90";

    this.setpopupobj = function (popupobj){
        this.popupobj = popupobj;
    }
    this.ShowEditView = function(targetid){
        var width = parseInt(CrmPopup.getClientWidth()* 0.8);
        var popupobj=CrmPopup.load("","","",width,'SalesGoal',"","","","");
        this.setpopupobj(popupobj);

        this.targetid = targetid;
        var surl = "index.php?module=SalesGoal&file=SalesGoalEdit&action=SalesGoalAjax";
        surl += '&mode=edit&targetid='+this.targetid;

        ldAjax(surl,'',function(data){
            if(data.code == 1){
                var result = data.result;
                that.popupobj.setParams(result.title, that.SaveSalesGoal, "", width,'SalesGoal', "", result.oktext, "", result.canceltext);
                CrmPopup.setPopupobjHtmlContent_scroll(that.popupobj,result.content);

                that.divid = that.popupobj.divid;
                that.entitytype_arr = result.all_entitytype_arr;
                that.mainfield_arr = result.main_field_arr;
                that.detailfield_arr = result.detail_field_arr;
                that.funname_arr = result.funname_arr;
                that.approvedemand_arr = result.approvedemand_arr;
                that.label_arr = result.label_arr;
                that.popupobj.getDetailTableObj = function (){
                    var tableobj = ld("#"+this.divid+" #SalesGoalDetail");
                    return tableobj;
                }

                that.setEvent();
                that.setDetailinfo(result.detailinfo);
                CrmPopup.fullScreen(ld("#" + that.popupobj.divid), that.popupobj);
                CrmPopup.center(ld("#" + that.popupobj.divid), that.popupobj);

                that.updateBlocklist();
                var blocklist_obj=ld('#'+that.divid+' .block-list');
                ld.each(blocklist_obj,function(tmpindex,tmpblockobj){//wym XUQIU1002285 新增编辑界面，点击左侧快速定位到指定区块
                    ld(tmpblockobj).unbind("click").bind("click", function () {
                        that.blocklist_anchor(this);
                    })
                })
                ld("#" + that.divid + " .dvpopupsroll").get(0).addEventListener('scroll', that.blocklist_scroll);
                that.blocklist_scroll();//一进界面先触发一下滚动事件
            }else if(data.code == -1){
                RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", data.msg);
            }
        })
    }
    //为页面上的字段设置触发事件
    this.setEvent = function(){
        //指标对象
        var popupobj = that.popupobj;
        var modulenameobj = ld("#"+popupobj.divid+" #modulename");
        //指标对象切换事件
        modulenameobj.unbind('change').bind('change',function (){
            var cur_value = ld(this).val();
            if(cur_value == 'Users'){
                ld("#"+popupobj.divid).find('[name=dv_chzn_groupsetting]').show()
                ld("#"+popupobj.divid+" #groupsettinglabel").show();
                ld("#" + that.divid + " #displayinactiv,#displayinactiv_label").show();
            }else{
                ld("#"+popupobj.divid).find('[name=dv_chzn_groupsetting]').hide();
                ld("#"+popupobj.divid+" #groupsettinglabel").hide();
                ld("#" + that.divid + " #displayinactiv,#displayinactiv_label").hide();
            }

            ld("#"+popupobj.divid+" #clearscope").click();

            var surl = "index.php?module=SalesGoal&file=SalesGoalAble&action=SalesGoalAjax";
            surl += '&mode=getRelatedModule&frommodule='+cur_value;
            ldAjaxNoProgress(surl,'',function (data){
                if(data.code == 1){
                    that.entitytype_arr = data.result.all_entitytype_arr;
                    that.mainfield_arr = data.result.main_field_arr;
                    that.detailfield_arr = data.result.detail_field_arr;

                    ld("#"+popupobj.divid+" #detaillabelinfo").remove();
                    that.cur_rowindex = 0;
                    that.addDetailRow('');
                }
            })


        })
        //选择目标范围
        var choosescopeobj = ld("#"+popupobj.divid+" #choosescope");
        choosescopeobj.on('click',function () {
            var choosemodule = modulenameobj.val();
            if(choosemodule == 'Users'){
                getJsScript('include/js/ScopePopup/ScopePopup_Details.js',function () {
                    var scopepopupobj = ScopePopup_Details.getInstance();
                    var selectedtype = ld("#"+popupobj.divid+" #scope").val();
                    var selectedid = ld("#"+popupobj.divid+" #scopeid").val();
                    //XUQIU20240415-03 目标管理，增加“显示离职成员”参数（杨雅媚）wsh 20240918
                    if (ld("#"+popupobj.divid+' #displayinactiv').prop('checked')){
                        scopepopupobj.displayinactiv = 'yes';
                    } else{
                        scopepopupobj.displayinactiv = 'no';
                    }
                    scopepopupobj.allocateTemplate(this, 0, 0,selectedid ,selectedtype , 'SalesGoal');
                    scopepopupobj.validate_url = function (){
                        selectedtype = ld('#'+scopepopupobj.firstpop_id+'content input[name="radiotype"]:checked ').val();
                        ld("#"+popupobj.divid+" #scope").val(selectedtype);
                        if(selectedtype != 0){
							//XUQIU20240415-03 目标管理，增加“显示离职成员”参数（杨雅媚）wsh 20240918
                            if (cls_ScopePopup.return_obj.return_displayinactiv == 'yes') {
                                ld("#" + popupobj.divid + " #displayinactiv").prop('checked', true);
                            } else {
                                ld("#" + popupobj.divid + " #displayinactiv").prop('checked', false);
                            }
                            ld("#"+popupobj.divid+" #scopeid").val(cls_ScopePopup.return_obj.return_id);
                            ld("#"+popupobj.divid+" #scopeid_name").html(cls_ScopePopup.return_obj.return_name);
                            ld("#"+popupobj.divid+" #scopeid_name").attr('title',cls_ScopePopup.return_obj.return_name);
                        }else{
                            ld("#"+popupobj.divid+" #scopeid").val('all');
                            ld("#"+popupobj.divid+" #scopeid_name").html(arrJsPopLabel['ALLTHEUSERS']);
                            ld("#"+popupobj.divid+" #scopeid_name").attr('title',arrJsPopLabel['ALLTHEUSERS']);
                        }
                    }
                })
            }else{
                getJsScript('include/js/SystemPopup/MultiplePopup.js',function () {
                    var chooseentityidarr = [];
                    if(ld("#"+popupobj.divid+" #scopeid").val() != ''){
                        chooseentityidarr = ld("#"+popupobj.divid+" #scopeid").val().split(',');
                    }
                    var MultiplePopupobj = new MultiplePopup();
                    MultiplePopupobj.init(choosemodule,'','SalesGoal');
                    MultiplePopupobj.setChooseEntityidArr(chooseentityidarr);
                    MultiplePopupobj.showPopup();
                    MultiplePopupobj.setReturnField(popupobj,'scopeid','scopeid_name');
                })

            }
        })
        //清除目标范围
        var tmpdivid = popupobj.divid;
        ld("#"+popupobj.divid+" #clearscope").on('click',function (){
            ld("#"+tmpdivid+" #scope").val('');
            ld("#"+tmpdivid+" #scopeid").val('');
            ld("#"+tmpdivid+" #scopeid_name").html('');
            ld("#"+tmpdivid+" #scopeid_name").attr('title','');
        })

        //添加详情行
        ld("#"+popupobj.divid+" #addrow").on('click',function (){
            that.addDetailRow('');
        })
        /*wym BUG0071164 kfbcrm-英文版-目标管理这两个title是中文，改成tip*/
        tooltip('.tip-items-list',{transition:true,time:200});

    }

    this.SaveSalesGoal = function (){
        var popupobj = that.popupobj;
        //表头信息保存
        var divpopuobj = ld("#"+popupobj.divid);
        var label_arr = new Array('zhlabel','enlabel','modulename','groupsetting','scope','scopeid','smownerid','displayinactiv','indicator_unit','conversion_rate');
        var len = label_arr.length;
        var param = {};
        var tmp_label = '';
        var tmp_value = '';
        var tmp_obj = '';
        for (var i=0;i<len;i++){
            tmp_label = label_arr[i];
            tmp_obj = divpopuobj.find('#'+tmp_label);
            tmp_value = tmp_obj.val();
			//XUQIU20240415-03 目标管理，增加“显示离职成员”参数（杨雅媚）wsh 20240918
            if (tmp_label == 'displayinactiv'){
                if (tmp_obj.prop('checked')){
                    tmp_value = 'yes';
                }else {
                    tmp_value = 'no';
                }
            }
            if(empty(tmp_value) && tmp_label != 'scope'){
                if(tmp_label == 'scopeid'){
                    divpopuobj.find('#scopeid_name').addClass('border_red1');
                    divpopuobj.find('#scopeid_name').bind('mouseover',function(){
                        ld(this).removeClass('border_red1');
                    });
                    divpopuobj.find('#choosescope').bind('mouseover',function(){
                        divpopuobj.find('#scopeid_name').removeClass('border_red1');
                    });
                }else{
                    tmp_obj.addClass('border_red1');
                    tmp_obj.bind('mouseover',function(){
                        ld(this).removeClass('border_red1');
                    });
                }
                var remind_str = divpopuobj.find('#'+tmp_label).attr('remind_label')+arrJsPopLabel['CANOTEMPTY'];
                audioRemindsMsg("","","","","",remind_str);
                return false;
            }else{
                param[tmp_label] = tmp_value;
            }
        }

        //分录信息保存
        var detail_label_arr = new Array('entitytype','referencefield','datefield','funname','countfield','approvedemand','advance_demand','advance_demand_groups');
        var allow_empty_arr = new Array('approvedemand','advance_demand','advance_demand_groups');
        var label_len = detail_label_arr.length;
        //var trobjs = divpopuobj.find("#detaillabelinfo");
        var trobjs = ld("#"+popupobj.divid+" #detaillabelinfo");
        if(trobjs.length <= 0){
            var remind_str = divpopuobj.find('#detaititle').html()+arrJsPopLabel['CANOTEMPTY'];
            audioRemindsMsg("","","","","",remind_str);
            return false;
        }
        param['rowcnt'] = trobjs.length;
        var field_empty = 'no';
        var rowindex = 0;
        ld.each(trobjs,function (){
            rowindex ++;
            for(i=0;i<label_len;i++){
                tmp_label = detail_label_arr[i];
                tmp_value = ld(this).find('#'+tmp_label).val();
                if(empty(tmp_value) && allow_empty_arr.indexOf(tmp_label)==-1){
                    field_empty = 'yes';
                    return false;
                }else{
                    param[tmp_label+rowindex] = tmp_value;
                }
            }
        })
        if(field_empty == 'yes'){
            var remind_str = divpopuobj.find('#line_'+tmp_label).html()+arrJsPopLabel['CANOTEMPTY'];
            audioRemindsMsg("","","","","",remind_str);
            return false;
        }

        var surl = "index.php?module=SalesGoal&file=SalesGoalEdit&action=SalesGoalAjax";
        surl += '&mode=save&targetid='+that.targetid;
        var prevpopupobj = CrmPopup.getPopupObj('lastprev');
        ldAjax(surl,param,function(data){
            DelProgressObjs();
            if(data.code == 1){
                popupobj.CancelEvent();
                if(prevpopupobj.pagetype == 'SalesGoalList'){
                    cls_salesgoal_operation.RefreshListPopup();
                }else{
                    if(that.targetid == 0){
                        SalesGoalRefreshPicklist();
                    }else{
                        SalesGoalRefreshPicklist();
                        SalesGoalListClickSearch();
                    }
                }
            }else if(data.code == -1){
                //异常情况判断
                var divlabel = data.result.divlabel;
                divpopuobj.find('#'+divlabel).addClass('border_red1');
                divpopuobj.find('#'+divlabel).bind('mouseover',function(){
                    ld(this).removeClass('border_red1');
                });
                audioRemindsMsg("","","","","",data.msg);
                return false;
            }
        })
    }

    this.setDetailinfo = function (detailinfo){
        if(this.targetid >0){
            let popupobj = that.popupobj;
            let tmp_info = '';
            let trobj = '';
            for (let i = 0;i < detailinfo.length;i++){
                tmp_info = detailinfo[i];
                //添加分录行
                that.addDetailRow(tmp_info.entitytype);
                //指标模块赋值
                trobj = ld('#'+popupobj.divid+" tr[rowindex="+this.cur_rowindex+"]");
                trobj.find('#entitytype').val(tmp_info.entitytype);
                //设置分录事件
                trobj.find('#entitytype').trigger('change');
                //相关字段赋值
                trobj.find('#referencefield').val(tmp_info.referencefield);
                trobj.find('#funname').val(tmp_info.funname);
                //触发事件修改统计字段
                trobj.find('#funname').trigger('change');
                //相关字段赋值
                trobj.find('#countfield').val(tmp_info.countfield);
                trobj.find('#datefield').val(tmp_info.datefield);
                trobj.find('#approvedemand').val(tmp_info.approvedemand);
                trobj.find('#advance_demand').val(tmp_info.advft_criteria);
                trobj.find('#advance_demand_groups').val(tmp_info.advft_criteria_groups);
            }
        }else{
            this.addDetailRow('');
        }
    }

    this.addDetailRow = function (cur_entitytype){
        var all_html = '';
        var cur_rowindex = this.cur_rowindex;
        var new_rowindex = cur_rowindex+1;
        var entitytype_arr = this.entitytype_arr;
        if(empty(cur_entitytype)){
            cur_entitytype = entitytype_arr[0]['name'];
        }
        var i = 0;

        all_html += '<tr id="detaillabelinfo" class="dragtrrow" name="detaillabelinfo" rowindex="'+new_rowindex+'" style="height:46px">';
        all_html += '<td id="lineid" name="lineid" style="text-align: center;">'+new_rowindex+'</td>';
        var tdhtml = '';
        //指标模块

        var tdhtml_1 = '<td class="ld-form-item-content-entry" style="padding: 0px 10px 0px 0px;"><select class="'+that.selectClass+'" style="text-align: left;" id="entitytype" name="entitytype">';
        if(!empty(entitytype_arr) && entitytype_arr.length >0){
            for (i=0;i<entitytype_arr.length;i++){
                if(entitytype_arr[i].name == cur_entitytype){
                    tdhtml_1 += '<option value="'+entitytype_arr[i].name+'" selected>'+entitytype_arr[i].fieldlabel+'</option>';
                }else{
                    tdhtml_1 += '<option value="'+entitytype_arr[i].name+'">'+entitytype_arr[i].fieldlabel+'</option>';
                }
            }
        }
        tdhtml_1 += '</select>';
        tdhtml_1 += '</td>';
        all_html += tdhtml_1;

        //对象查询字段
        var tdhtml_2 = '<td><select class="'+that.selectClass+'" style="text-align: left;" id="referencefield" name="referencefield">';
        tdhtml_2 += that.getSelectHtml(cur_entitytype,'referencefield','','');
        tdhtml_2 += '</select>';
        tdhtml_2 += '</td>';
        all_html += tdhtml_2;

        // 日期字段
        var tdhtml_3 = '<td><select class="'+that.selectClass+'" style="text-align: left;" id="datefield" name="datefield">';
        tdhtml_3 += that.getSelectHtml(cur_entitytype,'datefield','','');
        tdhtml_3 += '</select>';
        tdhtml_3 += '</td>';
        all_html += tdhtml_3;

        // 计算方法
        var tdhtml_4 = '<td><select class="'+that.selectClass+'" style="text-align: left;" id="funname" name="funname">';
        for (i=0;i< that.funname_arr.length;i++){
            tdhtml_4 += '<option value="'+that.funname_arr[i].name+'">'+that.funname_arr[i].fieldlabel+'</option>';
        }
        tdhtml_4 += '</select>';
        tdhtml_4 += '</td>';
        all_html += tdhtml_4;

        // 统计字段
        var tdhtml_5 = '<td><select class="'+that.selectClass+'" style="text-align: left;" id="countfield" name="countfield">';
        tdhtml_5 += that.getSelectHtml(cur_entitytype,'countfield','sum','');
        tdhtml_5 += '</select>';
        tdhtml_5 += '</td>';
        all_html += tdhtml_5;

        //审批要求
        var tdhtml_6 = '<td><select class="'+that.selectClass+'" style="text-align: left;" id="approvedemand" name="approvedemand">';
        for (i=0;i<that.approvedemand_arr.length;i++){
            tdhtml_6 += '<option value="'+that.approvedemand_arr[i].name+'">'+that.approvedemand_arr[i].fieldlabel+'</option>';
        }
        tdhtml_6 += '</select>';
        tdhtml_6 += '</td>';
        all_html += tdhtml_6;

        //其他条件
        var tdhtml_7 = '<td style="text-align: center;" class="ld-form-item-content-entry">';
        tdhtml_7 += '<a href="javascript:;" id="othercondition" name="othercondition" >'+arrJsPopLabel['OTHERCONDITIONSJS']+'</a>';
        tdhtml_7 += '<input type="hidden" id="advance_demand" name="advance_demand" value="">';
        tdhtml_7 += '<input type="hidden" id="advance_demand_groups" name="advance_demand_groups" value="">';
        tdhtml_7 += '</td>';
        all_html += tdhtml_7;

        //操作
        var tdhtml_8 = '<td class="ld-form-item-content-entry">';
        tdhtml_8 += '<a href="javascript:;" id="delete" name="delete" >'+arrJsPopLabel['DELETE']+'</a>';
        tdhtml_8 += '</td>';
        all_html += tdhtml_8;

        all_html += '</tr>';

        var last_trobj = ld('#'+that.popupobj.divid+" tr[rowindex="+this.cur_rowindex+"]");
        last_trobj.after(all_html);

        var scrollobj = ld('#'+that.popupobj.divid+'_scroll').get(0);
        scrollobj.scrollTop = scrollobj.scrollTopMax;

        this.cur_rowindex ++;
        this.setDetailEvent(new_rowindex);
        this.popupobj.center();
    }

    //绑定详情切换事件
    this.setDetailEvent = function(rowindex){
        var popupobj = that.popupobj;
        var modulename = ld('#'+popupobj.divid+" #modulename").val();
        var trobj = ld('#'+popupobj.divid+" tr[rowindex="+rowindex+"]");
        //指标模块切换后需要更新后方的字段
        var entityobj = trobj.find("#entitytype");
        entityobj.unbind('change').bind('change',function (){
            var cur_obj = ld(this);
            var cur_entitytype = cur_obj.val();

            var main_field_arr = that.mainfield_arr[cur_entitytype];
            if(!empty(main_field_arr)){
                that.entitytype_change(cur_obj);
            }else{
                var surl = "index.php?module=SalesGoal&file=SalesGoalAble&action=SalesGoalAjax";
                surl += '&mode=getentityfield&entitytype='+cur_entitytype+'&frommodule='+modulename;
                ldAjaxNoProgress(surl,'',function (data){
                    if(data.code == 1){
                        that.mainfield_arr[cur_entitytype] = data.result.main_field_arr[cur_entitytype];
                        that.detailfield_arr[cur_entitytype] = data.result.detail_field_arr[cur_entitytype];
                        that.entitytype_change(cur_obj);
                    }
                })
            }
        });
        var cls_resetComboxHtmlobj=new cls_resetComboxHtml(entityobj.attr("name"));
        cls_resetComboxHtmlobj.trobj=trobj;
        cls_resetComboxHtmlobj.detailrowindex=rowindex;
        popupobj.detailfieldcolumninfo = new Array();
        cls_resetComboxHtmlobj.setPopupObj(popupobj);
        cls_resetComboxHtmlobj.setSearchComboxWidthByhtml(entityobj,140);

        //对象查询字段切换，选择分录的查询字段后只能选择分录的计算字段
        trobj.find('#referencefield').unbind('change').bind('change',function (){
            var trobj = ld(this).parents('tr');
            trobj.find('#funname').trigger('change');
        })
        //计算方法切换
        trobj.find('#funname').unbind('change').bind('change',function (){
            // 更新统计字段
            var cur_value = ld(this).val();
            var trobj = ld(this).parents('tr');
            var cur_entitytype = trobj.find('#entitytype').val();
            var fieldrange = trobj.find('#referencefield').find('option:selected').attr('fieldrange');

            var tmp_html = that.getSelectHtml(cur_entitytype,'countfield',cur_value,fieldrange);
            var countfieldobj = trobj.find('#countfield');
            var cur_field = countfieldobj.val();
            countfieldobj.html(tmp_html);
            countfieldobj.val(cur_field);
        });
        //设置其他条件
        trobj.find('#othercondition').on('click',function (){
            that.fun_other_conditions(this);
        })
        //删除分录
        trobj.find('#delete').on('click',function (){
            var trobj = ld(this).parents('tr');
            trobj.remove();

            var trobjs = ld('#'+popupobj.divid+" #detaillabelinfo");
            var lineid=0;
            if(trobjs.length >0){
                ld.each(trobjs,function (){
                    lineid++;
                    ld(this).attr('rowindex',lineid);
                    ld(this).find('#lineid').html(lineid);
                })
            }
            that.cur_rowindex = lineid;
        });
        // 计算方法
        var funnameobj = trobj.find('#funname');
        funnameobj.val('sum');
        funnameobj.trigger('change');
    }
    //分录的指标模块切换事件
    this.entitytype_change = function (obj){
        //指标模块
        var cur_entitytype = ld(obj).val();
        var main_field_arr = this.mainfield_arr[cur_entitytype];
        var detail_field_arr = this.detailfield_arr[cur_entitytype];
        var trobj = ld(obj).parents('tr');
        var i = 0;
        //对象查询字段
        var tdhtml_2 = that.getSelectHtml(cur_entitytype,'referencefield','','');
        trobj.find('#referencefield').html(tdhtml_2);

        // 日期字段
        var tdhtml_3 = that.getSelectHtml(cur_entitytype,'datefield','','');
        trobj.find('#datefield').html(tdhtml_3);

        // 计算方法
        var funnameobj = trobj.find('#funname');
        funnameobj.val('sum');
        funnameobj.trigger('change');

        //审批要求,其他条件
        trobj.find('#approve_demand').val(0);
        trobj.find('#advance_demand').val('');
        trobj.find('#c').val('');
    }

    this.getSelectHtml = function(cur_entitytype,cur_type,cur_value,fieldrange){
        var main_field_arr = this.mainfield_arr[cur_entitytype];
        var detail_field_arr = this.detailfield_arr[cur_entitytype];
        var tmp_html = '';
        var field_html = '';
        var tmp_field = '';
        if(!empty(main_field_arr) && main_field_arr.length >0&&fieldrange!='detail') {
            field_html = '';
            for (i = 0; i < main_field_arr.length; i++) {
                tmp_field =  main_field_arr[i];
                if(cur_type == 'referencefield'){
                    if(tmp_field.referencefield == 'yes'){
                        field_html += '<option value="'+tmp_field.column+'" fieldrange="main" >'+tmp_field.label+'</option>';
                    }
                }else if(cur_type == 'datefield'){
                    if(tmp_field.datefield == 'yes'){
                        field_html += '<option value="'+tmp_field.column+'">'+tmp_field.label+'</option>';
                    }
                }else if(cur_type == 'countfield' && cur_value == 'sum'){
                    if(tmp_field.counttotal == 'yes'){
                        field_html += '<option value="'+tmp_field.column+'">'+tmp_field.label+'</option>';
                    }
                }else{
                    field_html += '<option value="'+tmp_field.column+'">'+tmp_field.label+'</option>';
                }
            }
            if(!empty(field_html)){
                tmp_html += '<optgroup label="'+that.label_arr.DOCUMENTHEADERFIELD+'" class="select" style="border:none">'+field_html+'</optgroup>';
            }
        }
        if(!empty(detail_field_arr) && detail_field_arr.length >0) {
            field_html = '';
            for (i = 0; i < detail_field_arr.length; i++) {
                tmp_field =  detail_field_arr[i];
                if(cur_type == 'referencefield'){
                    if(tmp_field.referencefield == 'yes'){
                        field_html += '<option value="'+tmp_field.column+'" fieldrange="detail" >'+tmp_field.label+'</option>';
                    }
                }else if(cur_type == 'datefield'){
                    if(tmp_field.datefield == 'yes'){
                        field_html += '<option value="'+tmp_field.column+'">'+tmp_field.label+'</option>';
                    }
                }else if(cur_type == 'countfield' && cur_value == 'sum'){
                    if(tmp_field.counttotal == 'yes'){
                        field_html += '<option value="'+tmp_field.column+'">'+tmp_field.label+'</option>';
                    }
                }else{
                    field_html += '<option value="'+tmp_field.column+'">'+tmp_field.label+'</option>';
                }
            }
            if(!empty(field_html)){
                tmp_html += '<optgroup label="'+that.label_arr.Entryfield+'" class="select" style="border:none">'+field_html+'</optgroup>';
            }
        }
        return tmp_html;
    }
    this.fun_other_conditions = function (obj){
        var trobj = ld(obj).parents('tr');
        var rowindex = trobj.attr('rowindex');
        var frommodule = trobj.find('#entitytype').val();
        var advance_demandobj = trobj.find('#advance_demand');
        var advance_demand_groupsobj = trobj.find('#advance_demand_groups');
        if(empty(advance_demandobj.val())){
            var advancedemand = '[]';
            var  groupcondition='[]';
        }else{
            var advancedemand = trim(advance_demandobj.val());
            var groupcondition = trim(advance_demand_groupsobj.val());
        }

        var popupobj=CrmPopup.getPopupObj('last');
        var module = 'SalesGoal';
        var surl = 'index.php?module='+module+'&action='+module+'Ajax&file=SetOtherCondition&frommodule='+frommodule;
        var crmPopupobj=CrmPopup.load("","","","LdPopWidth800px",module,"","","","");
        var advft_criteria_groups_json = groupcondition;
        var advft_criteria_json = advancedemand;
        var params = {};
        if(!empty(advft_criteria_json)){
            params.advft_criteria = advft_criteria_json;
            params.advft_criteria_groups = advft_criteria_groups_json;
        }
        crmPopupobj.rowindex = rowindex;

        crmPopupobj.prevshow();
        ldAjaxNoProgress(surl,params,function(data){
            if(data.code==1){
                crmPopupobj.setParams(arrJsPopLabel['SettingOtherConditionJS'],that.set_advancedemand,'',"LdPopWidth800px",'Settings',"",data.result.oktext,"",data.result.canceltext,"");
                crmPopupobj.createScrollDiv();
                crmPopupobj.show(data.result.content);

                crmPopupobj.showvalues=data.result.showvalues;
                crmPopupobj.datetimestr=data.result.datetimestr;//基本查询
                crmPopupobj.viewnamelabel=data.result.viewnamelabel;
                crmPopupobj.modulelabel=data.result.modulelabel;
                crmPopupobj.columnname = '';

                var advanceFilterObj = new cls_advanceFilter();
                that.advanceFilterObj = advanceFilterObj;
                var params = {};
                params.columnOptionHtml = data.result.columns_block;
                params.fLabels = data.result.flabels;
                params.datetimestr = data.result.datetimestr;
                params.advfilterhtml = data.result.foption;
                params.fieldsinfo = data.result.fieldinfo;
                params.criteria_groups_arr = data.result.criteria_groups_arr;
                params.module = frommodule;
                // edit: xll 2024/11/8  XUQIU1001239  高级查找部分字段优化
                params.advanceFields = data.result.advanceFields;
                advanceFilterObj.showAdvanceFilter(crmPopupobj,params);
            }
        })
    }

    //获取高级查询条件
    this.set_advancedemand = function (){
        var popupobj = CrmPopup.getPopupObj('last');
        var rowindex = popupobj.rowindex;
        if(that.advanceFilterObj.checkAdvancedFilter()==false)
        {
            return false;
        }
        var advft_criteria = that.advanceFilterObj.advft_criteria;
        var advft_criteria_groups = that.advanceFilterObj.advft_criteria_groups;
        var trobj =  ld('#'+that.popupobj.divid+' #detaillabelinfo[rowindex='+rowindex+']');
        trobj.find("#advance_demand").val(advft_criteria);
        trobj.find("#advance_demand_groups").val(advft_criteria_groups);
        popupobj.CancelEvent();
    }

    this.checkAdvancedFilter = function (){
        return New_checkAdvancedFilter();
    }

    //XUQIU1002354 新增编辑界面优化
    this.updateBlocklist=function()
    {
        var blockobjs=ld("#"+that.divid+" [tag=headblock-title]:visible");
        var block_list = [];
        ld.each(ld(blockobjs),function(tmpindex,tmpblockobj){
            block_list[tmpindex]=ld(tmpblockobj).text();
        })
        var editleft_html = '<ul>';
        ld.each(block_list,function(tmpindex,tmpblock_label) {
            editleft_html += '<li><div class="block-list" block_index="'+tmpindex+'"><a title="'+tmpblock_label+'">'+tmpblock_label+'</a></div></li>';
        });
        editleft_html += '</ul>';
        ld("#"+that.divid+" .edit-left").html(editleft_html);
    }
    //wym XUQIU1002285 新增编辑界面，左侧增加快速定位到指定区块
    this.blocklist_anchor = function (obj) {
        var blockobj= ld('#'+this.divid+' .block-list.selected');
        ld(blockobj).removeClass('selected');
        ld(blockobj).find('a').css('color','#8392A7');
        ld(obj).addClass('selected');
        ld(obj).find('a').css('color','#3B7CFF');
        var target_index = ld(obj).attr('block_index'); // 获取点击的区块序号
        //XUQIU1002354 新增编辑界面优化
        var targetElement = ld("#"+that.divid+" [tag=headblock-title]").eq(target_index); // 查找对应序号的区块
        if (targetElement.length) {
            var scrollobj= ld('#'+this.divid+' .dvpopupsroll');
            var currentScrollPosition = ld(scrollobj).scrollTop();
            if(ld("#" + that.divid + '_head').length>0){
                var headheight = ld("#" + that.divid + '_head').outerHeight();
            }
            //点击事件不能触发滚动事件，先把右侧滚动条事件解绑
            ld(scrollobj).get(0).removeEventListener('scroll', that.blocklist_scroll);
            // 使用动画效果滚动到目标元素
            ld(scrollobj).get(0).scrollTop = currentScrollPosition+targetElement.offset().top-headheight-28;//非全屏再减去28

            // 等待一段时间，然后重新绑定滚动事件处理程序
            setTimeout(function () {
                ld(scrollobj).get(0).addEventListener('scroll', that.blocklist_scroll);
            }, 1000); // 1秒后重新绑定滚动事件处理程序
        }
    }
    //wym XUQIU1002285 右侧滚动，左侧选中当前区块
    this.blocklist_scroll = function () {
        //XUQIU1002354 新增编辑界面优化
        var blockobjs=ld("#"+that.divid+" [tag=headblock-title]"); //区块标题元素
        var headheight=0;
        if(ld("#" + that.divid + '_head').length>0){
            headheight = ld("#" + that.divid + '_head').outerHeight();
        }
        ld.each(ld(blockobjs),function(tmpindex,tmpobj){
            var targettop = ld(tmpobj).offset().top-headheight;
            if(targettop>=0){
                var select_blockobj= ld('#'+that.divid+' .block-list.selected');
                if(ld(select_blockobj).length>0){
                    ld(select_blockobj).removeClass('selected');
                    ld(select_blockobj).find('a').css('color','#8392A7');
                }
                var blockobjs= ld('#'+that.divid+' .block-list');
                if(targettop>0){//targettop大于零，则表示是上一个区块
                    if(tmpindex==0){ //BUG0077529 如果是第一个区块 则选中第一个
                        var cur_blockobj=ld(blockobjs).eq(tmpindex);
                    }else{
                        var cur_blockobj=ld(blockobjs).eq(tmpindex-1);
                    }
                }else if(targettop==0){//targettop等于零，则表示是当前区块
                    var cur_blockobj=ld(blockobjs).eq(tmpindex);
                }
                ld(cur_blockobj).addClass('selected');
                ld(cur_blockobj).find('a').css('color','#3B7CFF');
                return false;
            }
        })
    }
}

//获取当前类对象
cls_salesgoal_operation.getInstance=function(){
    var salesgoal_operationobj=new cls_salesgoal_operation();
    return salesgoal_operationobj;
}

//切换销售指标启用状态
cls_salesgoal_operation.ChangeSalesGoalStatus = function (obj){
    var targetid = ld(obj).attr('targetid');
    /*
    var status = 'no';
    if(ld(obj).prop('checked')){
        status = 'yes';
    }
    */
    var ShowBoardObj = ld(obj).parents('tr').find('input[tag=showboard]');
    //edit: xll 2023/08/14 目标管理中管理指标增加是否在看板显示参数控制
    var columnname = ld(obj).attr('columnname');
    var columnname_value = ld(obj).prop('checked')?'yes':'no';
   
    if(ld(obj).prop('checked')){
        if(columnname == 'status'){
            ShowBoardObj.css('cursor','pointer');
            ShowBoardObj.prop('disabled',false);
        }
    } else {
        if (columnname == 'status') {
            // 2024-11-19 xxy 至少开启一个
            var popupobj = CrmPopup.getPopupObj('last');
            var status_obj = ld("#"+popupobj.divid).find('#approvelisttable').find('input[columnname=status]:checked');
            ShowBoardObj.prop('checked',false);
            var showtype_obj = ld("#"+popupobj.divid).find('#approvelisttable').find('input[columnname=showtype]:checked');
            if(status_obj.length == 0 || showtype_obj.length == 0){
                var ContentText = arrJsPopLabel['REMAINONEINDICATOR'];
                MessagePopup.TipZero_warning(ContentText);
                ld(obj).prop('checked',true);
                ShowBoardObj.prop('checked',true);
                return false;
            }
            //edit: xll 2023/09/27 BUG0073321 管理指标-指标不启用时，“是否在看板显示”参数也应自动取消勾选 
            ShowBoardObj.css('cursor','not-allowed');
            ShowBoardObj.prop('disabled',true);
        }
    }
    //edit: xll 2023/08/19 BUG0071385 管理指标弹出层中，“ 是否在看板显示 ”关闭最后一个指标时，弹出提示信息“至少保留一个指标名称”
    var tag = ld(obj).attr('tag');
    if(tag == 'showboard'){
        var con = cls_salesgoal_operation.checkShowBoardNum(obj,columnname_value);
        if(con == false)
            return con;
    }
    //var surl = "&mode=changestatus&targetid="+targetid+"&status="+status;
    var surl = "&mode=changestatus&targetid="+targetid+"&columnname="+columnname+"&"+columnname+"="+columnname_value+"&tag="+tag;
    cls_salesgoal_operation.SimpleRequest(surl);
}
//edit: xll 2023/08/19 BUG0071385 管理指标弹出层中，“ 是否在看板显示 ”关闭最后一个指标时，弹出提示信息“至少保留一个指标名称”，英文标签：Reserve at least one indicator name
cls_salesgoal_operation.checkShowBoardNum = function (obj,type){
    var ShowBoardNumDiv = ld(obj).parents('#approvelisttable').parent();
    var ShowBoardNum = ShowBoardNumDiv.attr('ShowBoardNum');
    ShowBoardNum = parseInt(ShowBoardNum);
    if(type == 'yes'){
        ShowBoardNum += 1;
    } else {
        ShowBoardNum -= 1;
    }
    ShowBoardNum = parseInt(ShowBoardNum);
    if(ShowBoardNum == 0){
        //弹提示
        //禁止关闭
        ld(obj).prop('checked',true);
        var ContentText = arrJsPopLabel['REMAINONEINDICATOR'];
        MessagePopup.TipZero_warning(ContentText);
        //MessagePopup.TipZero_error(ContentText)
        return false;
    }
    ShowBoardNumDiv.attr('showboardnum',ShowBoardNum);
    return true;
}

//销售指标上移下移
//edit: xll 2023/09/01 BUG0071424 目标管理改为托拽排序
cls_salesgoal_operation.SalesGoalMove = function(salesgoalSeqArr){
    var SalesGoalSeqInfo = JSON.stringify(salesgoalSeqArr);
    if(!empty(SalesGoalSeqInfo) && SalesGoalSeqInfo != ''){
        var surl = "&mode=move&SalesGoalSeqInfo="+SalesGoalSeqInfo;
        cls_salesgoal_operation.SimpleRequest(surl);
    }
}

//设置拖动排序事件
cls_salesgoal_operation.setTableSort=function()
{
    var popupobj=CrmPopup.getPopupObj("last");
    var tableobj=ld("#"+popupobj.divid+" #approvelisttable");
    if(ld(tableobj).find("tbody").find(" .drag-handle").length<=1)
    {
        ld(tableobj).find("tbody").find(" .drag-handle").css("display",'none')
    }
    var tbody=ld(tableobj).find("tbody").get(0);
    Sortable.create(tbody,{
        draggable: ".dragtrrow",  // 允许拖拽的项目类名,否则会拖拽到小计行
        //	animation: 500,
        handle: '.drag-handle',
        onStart:function(evt){
            evt.preventDefault();
            evt.stopPropagation();
        },
        onUpdate: function (/**Event*/evt) {
            // same properties as onEnd
            evt.preventDefault();
        },
        onEnd: function (evt) {	//移动行
            var salesgoalSeqArr = {}
            ld.each(ld(tableobj).find("tbody").find('tr:not(:first)'),function(index,trobj){
                ld(this).find('td:first').html(index+1);
                ld(this).attr('rowindex',index+1);
                var tmp_targetid = ld(trobj).attr('targetid');
                salesgoalSeqArr[tmp_targetid] = index+1;
            });
            cls_salesgoal_operation.SalesGoalMove(salesgoalSeqArr);
            cls_salesgoal_operation.ResetRowEvent();
        }
    });
}
cls_salesgoal_operation.ResetRowEvent = function(){
    var popupobj = CrmPopup.getPopupObj('last');

    var trobjs = ld("#"+popupobj.divid+" #Goalinfo");
    var trlen = trobjs.length;
    var i = 0;
    var default_class = '';
    ld.each(trobjs,function (){
        i++;
        //var moveupobj = ld(this).find('#moveup');
        //var movedownobj = ld(this).find('#movedown');
        //edit: xll 2023/10/12 BUG0072591 kfbcrm-目标管理-管理指标界面，拖动导致颜色不对 
        if(i % 2 == 0){
            default_class = 'lvtColData';
            ld(this).removeClass('lvtColDataBj');
        }else{
            default_class = 'lvtColDataBj';
            ld(this).removeClass('lvtColData');
        }
        ld(this).addClass(default_class);
        //ld(this).attr('class',default_class);
        ld(this).attr('default_class',default_class);
        ld(this).unbind('mouseover').bind('mouseover',function (){
            ld(this).addClass('lvtColDataHover');
            //this.className = 'lvtColDataHover';
        });
        ld(this).unbind('mouseout').bind('mouseout',function (){
            ld(this).removeClass('lvtColDataHover').addClass(ld(this).attr('default_class'));
            //this.className = ld(this).attr('default_class');
        });
        /*
        if(i == 1){
            moveupobj.hide();
            movedownobj.show();
        }else if(i == trlen){
            moveupobj.show();
            movedownobj.hide();
        }else{
            moveupobj.show();
            movedownobj.show();
        }
         */
    })
}
cls_salesgoal_operation.Delete = function (obj){
    var targetid = ld(obj).attr('targetid');
    var remind_str = arrJsPopLabel['INDICATORDELETEREMIND'];
    RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", remind_str);
    var cur_popupobj = CrmPopup.getPopupObj('last');
    ld("#"+cur_popupobj.divid+" input[tagclick='msgConfirm']").on('click',function (){
        var surl = "&mode=delete&targetid="+targetid;
        cls_salesgoal_operation.SimpleRequest(surl);
        cls_salesgoal_operation.RefreshListPopup();
    });
}

cls_salesgoal_operation.Allocate = function (obj){
    var targetid = ld(obj).attr('targetid');
    var module = 'SalesGoal';
    var popup_type = 'ChangeCreator';
    var popup_url = 'module=Users&action=UsersAjax&file=changecreatorPop&popup_scopetype=public&popup_module=SalesGoal&popup_inputtype=radio&popup_selecttype=user&popup_type=' + popup_type;
    getJsScript('include/js/ScopePopup/ScopePopupObj.js', function () {
        var methodObj = {'popup_check_inactiveuser': 'yes', 'popup_check_nogroupuser': 'no'};
        scopepopupobj = new ScopePopupObj(methodObj);
        scopepopupobj.popup_caption_value = '分配';//标题title
        getJsScript('include/js/ScopePopup/ScopePopup.js', function () {
            cls_ScopePopup.prop.popup_url = popup_url;//popup_url
            cls_ScopePopup.prop.popup_module = module;//模块
            cls_ScopePopup.prop.popup_value = '';
            var cls_ScopePopups = new cls_ScopePopup(scopepopupobj);
            //重写确认按钮事件
            scopepopupobj.setEventBtnOk = function () {
                ld('#' + cls_ScopePopup.popup_divid + ' .E_pbtn .E_pbtnok').unbind('click').on('click', function () {
                    //没有选择任何用户，则给出提示
                    if (empty(cls_ScopePopup.return_obj.return_id)) {
                        var confirm_str = arrJsPopLabel['PLEASESELECTLESTONEUSER'];
                        RemindsMsg("", "LdPopWidth400px", module, "yes", "yes", confirm_str);
                        return false;
                    } else {
                        ld('#' + cls_ScopePopup.popup_divid + ' .D_pbtn .D_pbtnok').attr("disabled", true);
                        var selected_user = cls_ScopePopup.return_obj.return_id;//选中的用户
                        cls_ScopePopup.popupobj.CancelEvent();
                        //保存分配结果
                        var surl = "&mode=Allocate&targetid="+targetid+"&smownerid="+selected_user;
                        cls_salesgoal_operation.SimpleRequest(surl);
                        cls_salesgoal_operation.RefreshListPopup();
                    }
                });
            }
        });
    });
}
//指标共享操作
cls_salesgoal_operation.Share = function (obj){
    var targetid = ld(obj).attr('targetid');
    var shareduserid = ld(obj).attr('shareduserid');
    var rModule = 'SalesGoal';

    var scopepopupobj;
    //自定义弹出层页面html，绑定事件
    getJsScript('include/js/ScopePopup/ScopePopupObj.js',function(){
        var methodObj = {'popup_check_inactiveuser':'yes','popup_check_nogroupuser':'no'};
        scopepopupobj =  new ScopePopupObj(methodObj);
        scopepopupobj.popup_caption_value = arrJsPopLabel['SHARE'];//标题
        scopepopupobj.header = '<input type="radio" name="share_type" value="cover" checked="checked" hidden/>';
        scopepopupobj.popup_header += '<div class="select-input"><label class="padL0">'+arrJsPopLabel['LBL_SEARCHCHOOSE']+'</label><input type="text" class="ld-input-inner width150 marLR10" id=\'popup_locationdiv\' placeholder= \''+arrJsPopLabel['PLEASEINPUTYOUWANTTOFINDTHEUSER']+'\'><input id=\'viewuser_unfoldsubgroup\' type="checkbox" ><label for=\'viewuser_unfoldsubgroup\'>'+arrJsPopLabel['SUBGROUPUNFOLD']+'</label></div>';
        getJsScript('include/js/ScopePopup/ScopePopup.js',function(){
            //获取选择用户信息
            cls_ScopePopup.prop.popup_module = rModule;//模块
            cls_ScopePopup.prop.popup_value = shareduserid;
            cls_ScopePopup.prop.popup_url = "module=Users&action=UsersAjax&file=viewuserinfo&popup_scopetype=public&popup_module="+rModule+"&popup_inputtype=checkbox&popup_selecttype=user&fieldname=team_memberid";
            var cls_ScopePopups = new cls_ScopePopup(scopepopupobj);
            //确认按钮事件
            scopepopupobj.setEventBtnOk=function(){
                ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtnok').unbind('click').on('click',function(){
                    //选中的用户
                    var selected_user = cls_ScopePopup.return_obj.return_id;
                    ld(obj).attr('shareduserid',selected_user);
                    //选中的共享类型
                    ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtncancel').click();
                    //保存共享的用户
                    var surl = "&mode=Share&targetid="+targetid+"&shareuserids="+selected_user;
                    cls_salesgoal_operation.SimpleRequest(surl);
                });
            }
        });
    });
}


cls_salesgoal_operation.RefreshListPopup = function (){
    var popupobj = CrmPopup.getPopupObj('last');
    var surl = "index.php?module=SalesGoal&file=SalesGoalAble&action=SalesGoalAjax&mode=list";
    ldAjax(surl,'',function(data){
        DelProgressObjs();
        if(data.code == 1){
            var result = data.result;
            ld("#"+popupobj.divid+"_scroll").html(result.content);
            cls_salesgoal_operation.ResetRowEvent();
        }else if(data.code == -1){
            RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", data.msg);
        }
    })
}
//销售目标的简单请求，不需要对返回值做处理
cls_salesgoal_operation.SimpleRequest = function (extra_url){
    var surl = "index.php?module=SalesGoal&file=SalesGoalAble&action=SalesGoalAjax";
    surl += extra_url;
    ldAjaxNoProgress(surl,'',function(data){
        if(data.code == 1){
        }else if(data.code == -1){
            RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", data.msg);
        }
    })
}
//刷新销售目标列表
cls_salesgoal_operation.RefreshList = function (){
    var tableindex = ld('.ld-ui-tabs-active').attr('tabindex');
    SalesGoalTabClick(parseInt(tableindex));
}


