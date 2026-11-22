/*
* edit:duan
* reason:
* */

//自动化进度功能页面设置相关js
function cls_advance_process(popupobj,frommodule){
    AjaxJSPage('cls_advance_node_preview_js','include/js/modules/process/cls_advance_node_preview.js');
    AjaxJSPage('cls_advance_node_js','include/js/modules/process/cls_advance_node.js');

    var that=this;
    this.modulename = frommodule;
    this.popupobj = '';
    this.picklist_arr = new Array();
    this.choosedpicklist_arr = new Array();
    this.prevpopupobj = '';

    //显示后台设置界面
    this.showsetting = function (){
        var surl = 'index.php?module=Settings&action=SettingsAjax&file=AdvanceProcessSet&modulename='+this.modulename+'&sub_mode=preview';
        ldAjaxNoProgress(surl,'',function (data){

            hidePageLayOutDiv();
            var html = that.showPreviewProcess();
            ld("#dv_advance_content").html(html);
            ld("#dv_advance").css("display",'');
            ld("#advprocesseditbtn").bind('click',function (){
                that.showPopup();
            })
            var module_advance = data.result.moduleadvance;
            if(!empty(module_advance)){
                var method = module_advance.method;
            }else{
                var method = '';
            }


            var stepinfo = data.result.stepinfo;

            var tmpobj = {};
            tmpobj.divid = 'dv_advance_content';
            that.CreatePreviewProcess(tmpobj,stepinfo,method);
        })
    }
    //显示预览效果图
    this.showPreviewProcess = function (){
        var edit_text = arrJsPopLabel['EDIT'];
        var html = '<table id="dv_advance_title" border="0" cellspacing="0" cellpadding="0" width="100%" class="DetailContentTable linefeed" style="">\n' +
            '<tbody><tr><td colspan="4" class="editrelhead">\n' +
            '<b>'+arrJsPopLabel['PROGRESSSETTINGSPREVIEW']+'</b><input style="margin-left: 20px;" id="advprocesseditbtn" type="button" class="ld-button ld-button-primary" alt="'+edit_text+'" title="'+edit_text+'" value="'+edit_text+'">\n' +
            '</td></tr></tbody>\n' +
            '</table>' +
            '<div id="parent_node" name="parent_node" class="HorizontalProcess-design" style="height: 100%;"></div>' +
            '<div style="position: absolute;top: 90px;"></div>';
        return html;
    }

    //详情页进度预览图
    this.CreateDetailPreviewProcess = function (crmPopupobj,stepinfo,module_advacne){
        var divobj = ld("#"+crmPopupobj.divid);
        var parent_obj = divobj.find("#parent_node");
        var advance_preview_obj= cls_advance_node_preview.load(crmPopupobj,this);
        this.prevpopupobj = crmPopupobj;
        advance_preview_obj.module = that.modulename;
        advance_preview_obj.module_advacne = module_advacne;
        advance_preview_obj.setshowtype('detail');
        advance_preview_obj.setparenthtml(parent_obj);
        advance_preview_obj.showprocess(stepinfo);
        parent_obj.show();

        divobj.find("#advprocesseditbtn").bind('click',function (){
            that.showPopup();
        })

        var show_btnobj = divobj.find("#advance_show_btn");
        show_btnobj.on('click',function (){
            //如果详情页默认手气,则区块展开后加载字段事件,且不能重复加载
            if(ld(this).data('setevent') == 'no'){
                that.setAdvancePadding(crmPopupobj);
                AdvanceStage.advance_load_tipevent();
                ld(this).data('setevent','yes');
            }
        })

        //如果详情页默认展开,则加载事件
        if(show_btnobj.data('setevent') != 'no'){
            AdvanceStage.advance_load_tipevent();
            show_btnobj.data('setevent','yes');
            this.setAdvancePadding(crmPopupobj);
        }
    }
    this.setAdvancePadding = function (crmPopupobj){
        //计算节点下方文本显示高度
        var divobj = ld("#"+crmPopupobj.divid);
        var show_btnobj = divobj.find("#advance_show_btn");
        var parent_node_wrapobj = divobj.find('#parent_node_wrap');
        var node_height = parent_node_wrapobj.height();
        var new_padding_bottom = 0;
        var icon_height = 0;
        var max_text_height = 0;
        var tmp_height = 0;
        var advancenode_arr =  divobj.find('[tag=advance_text_height]');
        if(advancenode_arr.length >0){
            ld.each(advancenode_arr,function (){
                tmp_height = 0;
                ld.each(ld(this).find('[tag=child_text_height]'),function (){
                    if(ld(this).height()>0){
                        tmp_height += ld(this).height();
                    }
                })
                icon_height = ld(this).find('[tag=stageicon]').height();
                tmp_height += icon_height/2;
                if(tmp_height > max_text_height){
                    max_text_height = tmp_height;
                }
            })
        }
        if(max_text_height >0){
            new_padding_bottom = max_text_height-node_height/2;
        }
        new_padding_bottom += 5; //跟下方的滚动条隔开一点距离

        if(new_padding_bottom < 15) new_padding_bottom = 15;
        divobj.find('[name=nodelist]').css('padding-bottom',new_padding_bottom);

        //如果存在分支，则需要计算分支所占的空间,
        var parent_branchobj = divobj.find('#parent_branch_wrap');
        if(parent_branchobj.length > 0){
            var width = parent_branchobj.width();
            var flex_num = Math.floor(width/200);//200是因为每一个节点的最小宽度是200，在正常情况下，/200 能表示分支内横向节点的最大数量
            parent_branchobj.css('flex-grow',flex_num);
            parent_branchobj.css('flex-shrink',1);
            parent_branchobj.css('flex-basis','0%');
        }
    }

    //后台设置预览图
    this.CreatePreviewProcess = function (crmPopupobj,stepinfo,method){
        var parent_obj = ld("#"+crmPopupobj.divid + " #parent_node");
        var advance_preview_obj= cls_advance_node.load(crmPopupobj,this);
        advance_preview_obj.module = that.modulename;
        advance_preview_obj.setshowtype('preview');
        advance_preview_obj.setparenthtml(parent_obj);
        if(method == 'period'){
            //var new_arr = this.createdateprocess();
            advance_preview_obj.showemptyprocess();
            parent_obj.hide();
        }else{
            parent_obj.show();
            advance_preview_obj.showprocess(stepinfo);

            var all_height = ld('.main_grid_box').height();
            var title_height = ld('#dv_advance_title').height();
            var header_height = ld('#LayoutBlocklistTable').height();
            var nodelistobj = parent_obj.find('[name=nodelist]');
            nodelistobj.css('height',(all_height-title_height-header_height-35)); //35 父节点到下方的高度，以及滚动条的高度
            nodelistobj.css('padding',20);

            //将滚动条放置到中央位置，便于查看
            var boxobj = parent_obj.find('#approveflow-design-box');
            var max_height =boxobj.height();
            var content_height = parent_obj.find('#parent_node_wrap').height();
            var scroll_height = (content_height-max_height)/2;
            if(scroll_height >0)boxobj.get(0).scrollTop = scroll_height;
        }
    }

    //显示推进设置弹出层
    this.showPopup = function (){
        var popwidth = CrmPopup.getClientWidth();
        var crmPopupobj=CrmPopup.load("","","",popwidth,'Settings',"","","","");
        crmPopupobj.createHeadHtml = function () {
            this.popupheadhtml = '<div class="E_pop_tit" id="' + this.divid + '_head" style="cursor:move">';
            this.popupheadhtml += '<strong class="E_ptita">' + this.headtitle + '</strong>';

            this.popupheadhtml+='<div class="E_pop_tit_Second_Right">';
            this.popupheadhtml += '<input class="ld-button ld-button-primary" style="float: right;" type="button" value="'+arrJsPopLabel['SAVE']+'" id="btn_advancesave" name="btn_advancesave">';
            this.popupheadhtml += '<div class="E_ptitc tip-items-pop" value="' + arrJsPopLabel['LBL_CLOSE'] + '" data-tip="' + arrJsPopLabel['LBL_CLOSE'] + '" data-direction="bottom" data-type="position"  id="' + this.divid + '_imgclose"></div>';

            this.popupheadhtml += '</div>';
            this.popupheadhtml += '</div>';

        }

        crmPopupobj.prevshow();
        this.popupobj = crmPopupobj;

        var surl = 'index.php?module=Settings&action=SettingsAjax&file=AdvanceProcessSet&modulename='+that.modulename+'&sub_mode=popupset';
        ldAjaxNoProgress(surl,'',function (data){
            crmPopupobj.setParams(data.result.title,'',"",popwidth,'Settings',"",'',"",'',"");
            var htmlcontent = that.setPopupContentHtml(data.result);
            var stepinfo = data.result.stepinfo;
            //crmPopupobj.show(htmlcontent);
            CrmPopup.setPopupobjHtmlContent_scroll_jquery(crmPopupobj,htmlcontent)

            var module_advance = data.result.moduleadvance;

            if(!empty(module_advance)){
                var method = module_advance.method;
            }else{
                var method = '';
            }
            that.CreateProcess(crmPopupobj,stepinfo,'edit',method);

            that.setChangeEvent();
        })

    }
    //生成弹出层设置界面
    this.setPopupContentHtml = function (returndata){
        var html = '';
        var headhtml = '';
        var widowheight = CrmPopup.getClientHeight()*1 - ld('#'+this.popupobj.divid+'_head').outerHeight();
        var main_html = '<div class="ld-flex-div-position" style="width: calc(100% - 5px);height:'+widowheight+'px" >';
        var left_html = '<div class="ld-main-advance-set" id="ld-main-advance-set" >';
        left_html += '<div class="ld-from-headblock-title"><span>'+arrJsPopLabel['BASICINFORMATION']+'</span></div>';
        var tmp_info = {};
        var tmp_option_info = {};
        var moduleadvance_arr = returndata.moduleadvance;
        //显示左侧设置按钮,是否启用进度追踪

        for(var i = 0;i<returndata.checkbox.length;i++){
            tmp_info = returndata.checkbox[i];
            left_html += '<div class="ld-children-advance-set">' +
                '<div class="ld-children-advance-label"><span>'+tmp_info.label+'</span></div>' +
                '<div class="ld-children-advance-field"><input type="checkbox" class="second_switch" id="'+tmp_info.divid+'" name="'+tmp_info.divid+'" ';
            if(moduleadvance_arr[tmp_info.divid] == 'yes'){
                left_html += ' checked = "" ';
            }
            left_html += '/></div></div>';
        }
        //相关下拉框设置
        var displaystyle = '';
        for(var i = 0;i<returndata.selectdom.length;i++){
            tmp_info = returndata.selectdom[i];
            displaystyle = '';
            if(moduleadvance_arr['method'] == 'period' && (tmp_info.divid == 'operatestyle' || tmp_info.divid == 'logshowstyle' || tmp_info.divid == 'module_field')){
                displaystyle = ' style="display:none" ';
            }else if(moduleadvance_arr['method'] != 'period' && (tmp_info.divid == 'module_period_start_date_field' || tmp_info.divid == 'module_period_end_date_field')){
                displaystyle = ' style="display:none" ';
            }

            left_html += '<div children_divid="'+tmp_info.divid+'" class="ld-children-advance-set" '+displaystyle+' >' +
                '<div class="ld-children-advance-label"><span>'+tmp_info.label+'</span></div>' +
                '<div class="ld-children-advance-field"><select class="ld-select-inner" id="'+tmp_info.divid+'" name="'+tmp_info.divid+'" >';
            if(tmp_info.divid == 'module_field'){ //追踪字段允许设置为空值
                left_html += '<option value = ""></option>';
            }
            for(var tmpkey in tmp_info.option){
                left_html += '<option value="'+tmpkey+'" ';

                var tmp_divid = tmp_info.divid;
                if (moduleadvance_arr['method'] == 'period'){
                    if (tmp_divid == 'module_period_start_date_field'){
                        tmp_divid = 'module_period_start_field';
                    }else if (tmp_divid == 'module_period_end_date_field'){
                        tmp_divid = 'module_period_end_field';
                    }
                }
                if(moduleadvance_arr[tmp_divid] == tmpkey){
                    left_html += ' selected = "" ';
                }
                left_html += '>'+tmp_info.option[tmpkey]+'</option>';
            }

            left_html += '</select></div></div>';
        }

        //追踪字段下拉框值列表
        //wym XUQIU1002497 多分支PC端设置界面优化 先隐藏
        //left_html += '<div children_divid="module_field_text" style="font-size: 12px;text-align: center;padding-top: 10px;" >'+arrJsPopLabel['DRAGTORIGHTSTEP']+'</div>'
        left_html += '<div id="picklistcontent" name="picklistcontent" style="overflow: auto;margin: 10px;" >';
        left_html += '<ul id="picklist_ul" class="ld-advance-picklistcontent" >';
        var picklistcontent_arr = returndata.picklistcontent;
        var tmp_value = '';

        if(moduleadvance_arr['method'] == 'field' && !empty(moduleadvance_arr['module_field'])){
            this.picklist_arr[moduleadvance_arr['module_field']] = picklistcontent_arr;
        }
        if(picklistcontent_arr != undefined && picklistcontent_arr.length >0){
            var selected_picklist = this.getselectedpicklist(returndata.stepinfo);
            for(var i = 0;i<picklistcontent_arr.length;i++){
                tmp_value = picklistcontent_arr[i];
                if(selected_picklist.includes(tmp_value)){
                    left_html += '<li class="advance-picklist-selected" >'+tmp_value+'</li>';
                }else{
                    left_html += '<li class="advance-picklist-unselect" >'+tmp_value+'</li>';
                }
            }
        }
        left_html += '<ul>';
        left_html += '</div>';



        left_html += '</div>';
        main_html += left_html;
        //右侧流程图预留空间
        var right_html = '<div id="parent_node" name="parent_node" class="HorizontalProcess-design" style="height: 100%;flex: 1;max-width: calc(100% - 400px);"></div>';
        main_html += right_html;
        main_html += '</div>';

        html = headhtml + main_html;
        return html;
    }

    //设置推进选项切换事件
    this.setChangeEvent = function (){
        //切换追踪方式
        var popupobj = this.popupobj;
        var methodobj = ld("#"+popupobj.divid+" #method");
        methodobj.unbind('change').bind('change',function (){
            var divobj = ld("#"+popupobj.divid);
            if(ld(this).val() == 'period'){
                divobj.find("[children_divid=operatestyle]").hide();
                divobj.find("[children_divid=logshowstyle]").hide();
                divobj.find("[children_divid=module_field]").hide();
                divobj.find("[children_divid=module_field_text]").hide();
                divobj.find("[children_divid=staytimemethod]").hide();
                divobj.find("#picklistcontent").hide();
                divobj.find("[children_divid=module_period_start_date_field]").show();
                divobj.find("[children_divid=module_period_end_date_field]").show();

                //var new_arr = this.createdateprocess();
                //that.advancenodeobj.setshowtype('preview');
                that.advancenodeobj.showemptyprocess();
            }else{
                divobj.find("[children_divid=operatestyle]").show();
                divobj.find("[children_divid=logshowstyle]").show();
                divobj.find("[children_divid=module_field]").show();
                divobj.find("[children_divid=module_field_text]").show();
                divobj.find("[children_divid=staytimemethod]").show();
                divobj.find("#picklistcontent").show();
                divobj.find("[children_divid=module_period_start_date_field]").hide();
                divobj.find("[children_divid=module_period_end_date_field]").hide();
                that.getPickListContent(divobj.find("#module_field").val());
                that.advancenodeobj.setshowtype('advance_edit');
            }

        });
        //切换追踪字段
        var module_fieldobj = ld("#"+popupobj.divid+" #module_field");
        module_fieldobj.unbind('change').bind('change',function (){
            that.getPickListContent(ld(this).val());
        });

        //保存按钮事件
        var btn_saveobj = ld("#"+popupobj.divid+" #btn_advancesave");
        btn_saveobj.bind('click',function (){
            that.before_save();
        })
    }

    //获取相应下拉框字段的选项和推进流程设置
    this.getPickListContent = function (fieldname){
        if(empty(fieldname)){
            console.log(fieldname);
            that.advancenodeobj.showemptyprocess();
            return '';
        }
        var surl = 'index.php?module=Settings&action=SettingsAjax&file=AdvanceProcessSet&modulename='+this.modulename+'&sub_mode=getpicklist';
        var param = {'fieldname':fieldname};
        ldAjaxNoProgress(surl,param,function (data){
            var picklistcontent = data.result.picklistcontent;
            that.picklist_arr[fieldname] = picklistcontent;
            var stepinfo = data.result.stepinfo;
            //that.setPickListContent(fieldname,stepinfo);
            if(stepinfo.length <= 0 ){
                var confirm_str = arrJsPopLabel['ADDDEFAULTPROCESS'];
                MessagePopup.TipTwo_warning(confirm_str);

                var remindobj = CrmPopup.getPopupObj('last');
                ld('#'+remindobj.divid+'_btnok').on('click',function (){
                    var new_arr =  that.set_default_field_process(picklistcontent);
                    that.advancenodeobj.showprocess(new_arr);
                })
                ld('#'+remindobj.divid+'_btncancel').on('click',function (){
                    that.advancenodeobj.showprocess(stepinfo);
                })
                ld('#'+remindobj.divid+'_imgclose').on('click',function (){
                    that.advancenodeobj.showprocess(stepinfo);
                })
            }else{
                that.advancenodeobj.showprocess(stepinfo);
            }

        })
        /*
        var pre_picklistcontent = this.picklist_arr[fieldname];
        if(pre_picklistcontent != undefined && pre_picklistcontent.length >0){
            that.setPickListContent(fieldname);
        }else{

        }
        */
    }

    // 设置下拉框内容显示
    this.setPickListContent = function (fieldname,stepinfo){
        var cur_picklistcontent = this.picklist_arr[fieldname];
        var picklist_html = '';
        var tmp_value = '';
        var picklist_html = '<ul id="picklist_ul" class="ld-advance-picklistcontent">';
        if(cur_picklistcontent != undefined && cur_picklistcontent.length >0){
            var selected_picklist = this.getselectedpicklist(stepinfo);
            for(var i = 0;i<cur_picklistcontent.length;i++){
                tmp_value = cur_picklistcontent[i];
                if(selected_picklist.includes(tmp_value)){
                    picklist_html += '<li class="advance-picklist-selected" >'+tmp_value+'</li>';
                }else{
                    picklist_html += '<li class="advance-picklist-unselect" >'+tmp_value+'</li>';
                }
            }
        }
        picklist_html += '</ul>';
        ld("#"+this.popupobj.divid+" #picklistcontent").html(picklist_html);
    }

    //保存前判断是否符合规则
    this.before_save = function (){
        var popupobj=that.popupobj;
        var divid=popupobj.divid;
        var divobj = ld("#"+divid);
        var _method = divobj.find('#method').val();
        var frommodule = that.modulename;
        var param = {};
        if(_method == 'period'){
            var start_date_field_obj = divobj.find('#module_period_start_date_field');
            var end_date_field_obj = divobj.find('#module_period_end_date_field');
            if(start_date_field_obj.val() == end_date_field_obj.val()){
                var start_date_field_label = start_date_field_obj.attr('tag');
                var end_date_field_obj_label = end_date_field_obj.attr('tag');
                var _msg = start_date_field_label + arrJsPopLabel['AND'] + end_date_field_obj_label + arrJsPopLabel['Cannotbesettothesamefield'];
                RemindsMsg("","LdPopWidth500px","","yes","yes",_msg);
                return false;
            }
        }

        var _url = 'index.php?module=Settings&action=SettingsAjax&file=AdvanceProcessSave&sub_mode=saveLayoutBlockAdvance&frommodule='+frommodule;
        //var state = ld("input[name='box_"+i+"']").is(':checked');
        var enable = divobj.find('#enable').is(':checked');
        //启用进度跟踪
        if(enable){
            _url += '&enable=yes';
        }else{
            _url += '&enable=no';
        }
        //进度跟踪方式
        _url += '&method='+divobj.find('#method').val();
        //选择跟踪字段
        _url += '&module_field='+divobj.find('#module_field').val();
        //选择起始日期字段
        _url += '&module_period_start_date_field='+divobj.find('#module_period_start_date_field').val();
        //选择截止日期字段
        _url += '&module_period_end_date_field='+divobj.find('#module_period_end_date_field').val();
        //显示推进人和时间
        var showadvancelog = divobj.find('#showadvancelog').val();
        _url += '&showadvancelog='+showadvancelog;

        //移动端启用进度跟踪
        var showadvancemobile = divobj.find('#showadvancemobile').is(':checked');
        if(showadvancemobile){
            _url += '&showadvancemobile=yes';
        }else{
            _url += '&showadvancemobile=no';
        }
        //推进操作样式
        _url += '&operatestyle='+divobj.find('#operatestyle').val();
        //推进日志显示样式
        _url += '&logshowstyle='+divobj.find('#logshowstyle').val();
        //详情页默认展开
        _url += '&defaultshow='+(divobj.find('#defaultshow').is(':checked')?'yes':'no');
        //详情页默认展开
        _url += '&staytimemethod='+divobj.find('#staytimemethod').val();

        var stepinfo = this.advancenodeobj.stepflow_arr;
        var length = stepinfo.length;
        var tmp_info = {};
        var stagevalue = '';
        var all_branch_value_arr = {};
        var tmp_branchnodeid = 0;
        var error_remind = 'no';


        for(var i =0;i<length;i++){
            tmp_info = stepinfo[i];
            if(tmp_info['nodetype'] == 'approver'){
                if(empty(tmp_info['nodeinfo']) || empty(tmp_info['nodeinfo']['stagevalue'])){
                    error_remind = 'yes';
                    audioRemindsMsg("","LdPopWidth500px","","yes","yes",arrJsPopLabel['STEPINFORMATIONCANNOTEMPTY']);
                }else{
                    tmp_branchnodeid = tmp_info['branchnodeid'];
                    stagevalue = tmp_info['nodeinfo']['stagevalue'];
                    //判断同一分支下阶段不能重复
                    if(empty(all_branch_value_arr[tmp_branchnodeid])){
                        all_branch_value_arr[tmp_branchnodeid] = new Array(stagevalue);
                    }else{
                        if(all_branch_value_arr[tmp_branchnodeid].includes(stagevalue)){
                            error_remind = 'yes';
                            audioRemindsMsg("","LdPopWidth500px","","yes","yes",'同一分支下阶段不能重复');
                        }else{
                            all_branch_value_arr[tmp_branchnodeid].push(stagevalue);
                        }
                    }
                }

                if(error_remind == 'yes'){
                    var boxobj = divobj.find('#child_node_wrap_box[nodeid='+tmp_info['nodeid']+']');
                    boxobj.addClass('border_red1');
                    setTimeout(function (){
                        boxobj.removeClass('border_red1');
                    },2000);
                    // 计算错误节点的相对位置
                    var all_parent_boxobj = divobj.find('#approveflow-design-box');
                    all_parent_boxobj.get(0).scrollTop = 0;
                    all_parent_boxobj.get(0).scrollLeft = 0;
                    var location_info = boxobj.get(0).getBoundingClientRect();
                    var scroll_height = location_info.top - all_parent_boxobj.height()/2;
                    var scroll_width = location_info.left - (all_parent_boxobj.width() + divobj.find('#ld-main-advance-set').width())/2
                    if(scroll_height >0)all_parent_boxobj.get(0).scrollTop = scroll_height;
                    if(scroll_width >0)all_parent_boxobj.get(0).scrollLeft = scroll_width;
                    return '';
                }
            }
        }

        param['stepinfo'] = stepinfo;

        ldAjax(_url,param,function(data){
            if(data.code == 1){
                DelProgressObjs();
                popupobj.CancelEvent();
                //var _msg = arrJsPopLabel['SUCCESSFULLYSAVED'];
                //MessagePopup.TipOne_success(_msg);

                if(!empty(that.prevpopupobj) && that.prevpopupobj.pagetype == DetailViewPage.pagetype){
                    DetailViewRelation.showpage_moduledetail(that.prevpopupobj);
                }else{
                    var tmpobj = {};
                    tmpobj.divid = 'dv_advance_content';
                    that.CreatePreviewProcess(tmpobj,that.advancenodeobj.stepflow_arr);
                }

                return false;
            }else{
                DelProgressObjs();
                RemindsMsg("","LdPopWidth400px","","yes","yes",data.msg);
                return false;
            }
        })


    }
    //加载流程图js
    this.CreateProcess =function (crmPopupobj,stepinfo,showtype,method){

        var parent_obj = ld("#"+crmPopupobj.divid + " #parent_node");
        var advance_node_obj= cls_advance_node.load(crmPopupobj,this);
        advance_node_obj.module = that.modulename;


        advance_node_obj.setparenthtml(parent_obj);
        if(method == 'period'){
            //var new_arr = this.createdateprocess();
            //advance_node_obj.setshowtype('preview');
            advance_node_obj.showemptyprocess();
        }else{
            advance_node_obj.setshowtype('advance_edit');
            advance_node_obj.showprocess(stepinfo);
        }

        that.advancenodeobj = advance_node_obj;
    }

    //绑定节点编辑弹出层点击事件
    this.bindPopupEvent = function (nodeid,crmpopupobj,cur_flowobj,fieldname){
        //切换当前阶段下拉框事件
        var cur_this = this;
        var crmpopup_divobj = ld("#"+crmpopupobj.divid);
        var divobj = crmpopup_divobj.find("#cur_stagevalue");
        tooltip(crmpopup_divobj.find("#advance_relation_list").find("b[tag=editrelation]"),{transition: true, time: 200});
        var new_arr = this.getPermitPicklist(fieldname,cur_flowobj.stepflow_arr,crmpopupobj.stagevalue);
        if(empty(new_arr) || new_arr.length<=0){
            divobj.html(arrJsPopLabel['NOAVAILABLEDROPDOWNOPTIONS']);
        }else{
            var title = arrJsPopLabel['CURRENTSTAGE']+':'+crmpopupobj.stagevalue;
            AjaxJSPage('ld_Select','include/js/component/ld_Select.js');
            var homeapproveobj = ld_Select.showSelect(divobj.get(0), {
                'list': new_arr,
                'width':'255px',
                'selectname': title,
                'classname':'ld-advance-curstage',
                'change': function (evt){
                    var label = arrJsPopLabel['CURRENTSTAGE']+':'+evt.NavBarItem.label;
                    divobj.find('.ld_Select-content').find('span').text(label);
                    divobj.find('.ld_Select-optionlist').hide();
                    ld(function (){
                        divobj.find('.ld_Select-optionlist').show();
                    })

                    var prevpopupobj = that.popupobj;
                    var frommodule = that.modulename;
                    var fieldname= ld('#'+prevpopupobj.divid).find('[name=module_field]').val();
                    var stagevalue = evt.NavBarItem.value;
                    crmpopupobj.stagevalue = stagevalue;
                    var tmp_value  = '';
                    var surl = 'index.php?module=Settings&action=SettingsAjax&file=AdvanceProcessSet&modulename='+frommodule+'&sub_mode=getadvancelist';
                    var param = {'fieldname':fieldname,'stagevalue':stagevalue};
                    var picklistcontent_arr = cur_this.picklist_arr[fieldname];
                    ldAjaxNoProgress(surl,param,function (data){
                        //设置阶段推进关系
                        var advancerelation = data.result.advancerelation;
                        var relation_html = cur_this.getAdvanceRelationHtml(fieldname,advancerelation,stagevalue,nodeid);
                        crmpopup_divobj.find('#advance_relation_list').html(relation_html);
                        cur_this.setAdvanceRelationEvent(crmpopupobj);
                    })
                }
            });
        }

        this.setAdvanceRelationEvent(crmpopupobj);

        //弹出层保存按钮事件
        ld("#"+crmpopupobj.divid+" #btn_nodesave").bind('click',function (){
            cur_flowobj.NodePopupSave(nodeid,crmpopupobj);
        })
    }

    this.setAdvanceRelationEvent = function (crmpopupobj){
        //关联关系按钮选中事件
        var crmpopup_divobj = ld("#"+crmpopupobj.divid);
        crmpopup_divobj.find("[tag=chooserelation]").bind('click',function (){
            //控制任务阶段的设置按钮是否显示
            var set_obj = ld(this).parent().find('[tag=editrelation]');
            if(ld(this).is(':checked')){
                set_obj.show();
                var presence = 'yes';
            }else{
                set_obj.hide();
                var presence = 'no';
            }
            //获取当前模块和关联追踪字段
            var frommodule = that.modulename;

            var module_field= crmpopupobj.fieldname;

            //开始阶段值和目标阶段值
            var stagename_target = ld(this).attr('stagevalue_target');
            var stagename_start = crmpopupobj.stagevalue;

            var url = 'index.php?module=Settings&action=SettingsAjax&file=SaveAdvanceRelation';
            var param = {'frommodule':frommodule,'module_field':module_field,'stagename_start':stagename_start,'stagename_target':stagename_target};
            param['presence'] = presence;
            //传值到后台进行保存
            ldAjaxNoProgress(url,param,function(data){
                if(data.code == 1){
                    set_obj.attr('advanceid',data.result.advanceid);
                }else if(data.code == -1){
                    ld(obj).prop('checked',!ld(obj).is(':checked'));
                    RemindsMsg("","LdPopWidth400px","","yes","",data.msg);
                }
            });
        })

        //自动化进度编辑弹出层
        crmpopup_divobj.find("[tag=editrelation]").bind('click',function (){
            AdvanceRelation.EditInfo(this);
        })
    }

    this.getAdvanceRelationHtml = function (fieldname,advancerelation,stagevalue,nodeid){
        var relation_html = '';
        var tmp_info =  {};
        var picklistcontent_arr = this.picklist_arr[fieldname];
        if(picklistcontent_arr != undefined && picklistcontent_arr.length >0 && stagevalue != ''){
            var step_arr = this.advancenodeobj.stepflow_arr;
            var new_arr = step_arr.slice();
            var flowindex = this.advancenodeobj.getFlowStepIndex(nodeid);
            // 控制未选择的下拉框值不允许设置推进,但是使用起来不够方便,先去掉,看以后怎么处理
            //new_arr[flowindex]['nodeinfo']['new_value'] = stagevalue;
            //var selected_picklist = this.getselectedpicklist(new_arr);
            //new_arr[flowindex]['nodeinfo']['new_value'] = '';
            //!selected_picklist.includes(tmp_value)
            relation_html += '<div class="ld-advance-relation-list-title">可流转到:</div>';
            var i = 0, j = 0,tmp_value = '';
            for (i=0;i<picklistcontent_arr.length;i++){
                tmp_value = picklistcontent_arr[i];
                if(stagevalue==tmp_value ){
                    continue;
                }
                if(!empty(advancerelation)){
                    tmp_info = {};
                    for (j = 0;j< advancerelation.length;j++){
                        if(tmp_value == advancerelation[j]['stagevalue']){
                            tmp_info = advancerelation[j];
                            break;
                        }
                    }
                }
                if(empty(tmp_info)){
                    tmp_info = {'presence':'no','advanceid':0,"classname": "icon-emptywrenchhand"};
                }
                if(tmp_info['presence'] == 'yes'){
                    tmp_info['check'] = "checked";
                    tmp_info['display'] = '';
                }else{
                    tmp_info['check'] = "";
                    tmp_info['display'] = 'display:none;';
                }
                relation_html += '<div class="ld-advance-relation-list-div">'
                relation_html += '<input type="checkbox" tag="chooserelation" stagevalue_target="'+tmp_value+'" '+tmp_info['check']+'>';
                relation_html += '<span>'+tmp_value+'</span>';
                relation_html += '<b class="'+tmp_info['classname']+'" tag="editrelation" data-tip="任务设置" data-direction="bottom" data-type="position" style="'+tmp_info['display']+'" advanceid="'+tmp_info['advanceid']+'"></b>';
                relation_html += '</div>';
            }
        }
        return relation_html;
    }
    this.getselectedpicklist = function (stepinfo){
        var new_arr = [];
        return new_arr;//duan 20240313 允许重复选择推进阶段
        if(!empty(stepinfo) && stepinfo.length>0){
            var length = stepinfo.length;
            var tmp_value = '';
            for(var i = 0;i<length;i++){
                if(!empty(stepinfo[i]['nodeinfo'])){
                    if(!empty(stepinfo[i]['nodeinfo']['new_value'])){
                        tmp_value = stepinfo[i]['nodeinfo']['new_value'];
                    }else{
                        tmp_value = stepinfo[i]['nodeinfo']['stagevalue'];
                    }

                    if(!new_arr.includes(tmp_value)){
                        new_arr.push(tmp_value);
                    }
                }
            }
        }
        //new_arr = [];
        return new_arr;
    }

    this.getPermitPicklist = function (fieldname,stepinfo,cur_value){
        var selected_picklist = this.getselectedpicklist(stepinfo);
        var picklistcontent_arr = this.picklist_arr[fieldname];
        var new_arr = [];
        var tmp_value = '';
        for (var i = 0;i<picklistcontent_arr.length;i++){
            tmp_value = picklistcontent_arr[i];
            if(tmp_value == cur_value){
                selected = true;
            }else if(!selected_picklist.includes(tmp_value)){
                selected = false;
            }else{
                continue;
            }
            new_arr.push({'value':tmp_value,'label':tmp_value,'selected':selected});
        }
        return new_arr;
    }

    this.setDragEvent = function (){
        var divid = this.popupobj.divid;
        Sortable.create(ld("#"+divid+" #picklist_ul").get(0), {
            group: {name: 'node',pull:'clone',put:false},
            sort:false,
            draggable:".advance-picklist-unselect",
            // 结束拖拽
            onEnd: function (evt) {
                var fromobj = evt.item;
                var newvalue = ld(fromobj).get(0).textContent;
                var targetobj = evt.to;
                var nodeid = ld(targetobj).find('[name=btn_setapproverstep]').attr('nodeid');

                if(ld(targetobj).attr('name')=='stagevalue_box' && nodeid >0){
                    that.advancenodeobj.setStepvalue(nodeid,newvalue);
                }
            },
        });
        document.body.ondrop = function (event) {
            event.preventDefault();
            event.stopPropagation();
        };

        ld.each(ld("#"+divid+" #parent_node").find("[name=stagevalue_box]"),function(index,obj){
            Sortable.create(ld(this).get(0), {
                //zkt 20230330 设置未不可向外拖拽pull:false  BUG0063486  “联系人图谱”，编辑时，直接将图谱中第一个区块的内容拖动到另第二个区块，第一个区块无法再添加新的内容，点击保存，刚刚编辑的内容没有保存
                group:{name: 'node',pull:true},
                sort:false,
                dropOnEmpty: true,
                filter:'.jiantou',
                onChoose: function (evt) {
                    //console.log(evt);
                },
                // 拖拽元素改变位置的时候
                onChange: function(evt) {
                    /*var fromobj = evt.from;
                    var from_nodeid = ld(fromobj).find('[name=btn_setapproverstep]').attr('nodeid');
                    var targetobj = evt.to;
                    ld(targetobj).find('[nodeid='+from_nodeid+']').css('display','none');
                    ld(targetobj).find('.advance-picklist-unselect').css('display','none');*/
                },
                // 拖拽元素改变位置的时候
                onRemove: function(evt) {
                },
                // 结束拖拽
                onEnd: function (evt) {
                    //尝试实现节点间拖拽
                    var fromobj = evt.from;
                    var from_name = ld(fromobj).attr('name');
                    var from_nodeid = ld(fromobj).find('[name=btn_setapproverstep]').attr('nodeid');
                    var targetobj = evt.to;
                    var target_nodeid = ld(targetobj).find('[name=btn_setapproverstep]').attr('nodeid');
                    var target_name = ld(targetobj).attr('name');
                    if(from_name =='stagevalue_box' && target_name =='stagevalue_box' ){
                        that.advancenodeobj.stepchangevalue(from_nodeid,target_nodeid);
                    }
                }
            });
        })
        ld.each(ld("#"+divid+" #parent_node").find("[name=btn_setcondition]"),function(index,obj){
            Sortable.create(ld(this).get(0), {
                //zkt 20230330 设置未不可向外拖拽pull:false  BUG0063486  “联系人图谱”，编辑时，直接将图谱中第一个区块的内容拖动到另第二个区块，第一个区块无法再添加新的内容，点击保存，刚刚编辑的内容没有保存
                group:{name: 'condition',pull:true},
                sort:false,
                dropOnEmpty: true,
                onChoose: function (evt) {
                    //console.log(evt);
                },
                // 拖拽元素改变位置的时候
                onChange: function(evt) {
                    /*var fromobj = evt.from;
                    var from_nodeid = ld(fromobj).attr('nodeid');
                    var targetobj = evt.to;
                    ld(targetobj).find('[nodeid='+from_nodeid+']').css('display','none');
                    ld(targetobj).find('.advance-picklist-unselect').css('display','none');*/
                },
                // 拖拽元素改变位置的时候
                onRemove: function(evt) {
                },
                // 结束拖拽
                onEnd: function (evt) {
                    //尝试实现节点间拖拽
                    var fromobj = evt.from;
                    var from_name = ld(fromobj).attr('name');
                    var from_nodeid = ld(fromobj).attr('nodeid');
                    var targetobj = evt.to;
                    var target_nodeid = ld(targetobj).attr('nodeid');
                    var target_name = ld(targetobj).attr('name');
                    if(from_name =='btn_setcondition' && target_name =='btn_setcondition' ){
                        that.advancenodeobj.stepchangevalue(from_nodeid,target_nodeid);
                    }
                }
            });
        })

    }
    //生成时间段的默认流程
    this.set_default_period_process = function (){
        return '';
        var year = new Date().getFullYear();
        var month_num = 12;
        var new_arr = [];

        var tmp_start = {id:"",childid:"1",nodetype:'start', nodename:arrJsPopLabel['LBL_START'],branchnodeid:'-1',nodeid:'-1',nodeinfo:[]};
        var new_nodeid = 1;
        new_arr.push(tmp_start);

        var tmp_step = '';
        for(var i = 1;i<= month_num ; i++){
            tmp_step = {id:"",childid:new_nodeid+1,nodetype:'approver',nodename:arrJsPopLabel['STEP']+'1',branchnodeid:"-1",nodeid:new_nodeid,nodeinfo:{'showlabel':year+'-'+i}};
            new_nodeid ++;
            new_arr.push(tmp_step);
        }
        return new_arr;
    }
    //生成下拉框字段的默认流程
    this.set_default_field_process = function (picklistcontent){
        var new_arr = [];
        var length = picklistcontent.length;
        if(length<=0){
            return new_arr;
        }

        var tmp_start = {id:"",childid:"1",nodetype:'start', nodename:arrJsPopLabel['LBL_START'],branchnodeid:'-1',nodeid:'-1',nodeinfo:[]};
        var new_nodeid = 1;
        new_arr.push(tmp_start);

        var tmp_step = '';
        var tmp_value = '';
        var tmp_childid = 0;
        for(var i = 0;i< length ; i++){
            tmp_value = picklistcontent[i];
            tmp_childid = new_nodeid+1;
            if(i == length-1)tmp_childid = '';

            tmp_step = {id:"",childid:tmp_childid+'',nodetype:'approver',nodename:arrJsPopLabel['STEP']+new_nodeid,branchnodeid:"-1",nodeid:new_nodeid,nodeinfo:{'stagevalue':tmp_value,'showlabel':tmp_value}};
            new_nodeid ++;
            new_arr.push(tmp_step);
        }
        return new_arr;
    }

}

