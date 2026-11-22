function cls_advance_node_preview(popupobj,advanceobj) {
    this.advanceobj = advanceobj;
    var that = this;

    this.innerNodeHtml = function() {
        var that = this;

        that.stepflowhtml = '';
        //console.log(that.stepflow_arr);
        that.createhtml(-1, that.stepflow_arr);

        that.stepflowhtml += that.endhtml(); //审批结束

        ld("#" + that.popupobj.divid + " [name=nodelist]").html(that.stepflowhtml);

        //that.popupobj.center();
        //that.setEvent();
    }

    this.createhtml = function(childid, arry) {
        var that = this;
        if (childid == '' || childid == ',')
            return '';
        var childArry = this.GetChildArry(childid, arry);

        if (childArry.length > 0) {


            var len = childArry.length;
            if (childArry[0].nodetype == 'condition') {
                //添加条件
                this.stepflowhtml += '<div class="branch-wrap" id="parent_branch_wrap">' +
                    '<div class="branch-box-wrap" style="min-height: max-content;flex-wrap: nowrap;">' +
                    '<div class="branch-box">';
            }


            for (var i = 0; i < len; i++) {


                if (childArry[i].nodetype == 'start') {
                    this.stepflowhtml += this.starthtml(childArry[i]);

                } else if (childArry[i].nodetype == 'approver') {
                    this.stepflowhtml += this.approvehtml(childArry[i]);

                } else if (childArry[i].nodetype == 'condition') {


                    if (i == 0)
                        this.stepflowhtml += this.conditionhtml(childArry[i], 'left');
                    else if (i == len - 1)
                        this.stepflowhtml += this.conditionhtml(childArry[i], 'right');
                    else
                        this.stepflowhtml += this.conditionhtml(childArry[i], 'middle');
                }


                this.createhtml(childArry[i].childid, arry);

                if (childArry[i].nodetype == 'condition') {
                    this.stepflowhtml += "</div>"
                }
            }

            if (childArry[0].nodetype == 'condition') {
                this.stepflowhtml += '</div>';
                //获取条件节点虚拟节点

                var virtualstepindex = that.getVirtualStepindex(childArry[0].branchnodeid);

                this.stepflowhtml += this.addconditionnodehtml(that.stepflow_arr[virtualstepindex]);
                this.createhtml(that.stepflow_arr[virtualstepindex].childid, arry);
                this.stepflowhtml += '</div></div>';
            }

        }
    }

    this.starthtml = function(nodeinfo) {
        var classname = '';
        if(!empty(nodeinfo.classname)){
            classname = nodeinfo.classname;
        }
        var html = '';
        if(classname == 'start_stage'){
            html = ' <div class="node-wrap" id="parent_node_wrap" style="min-width:100%;">';
            html += this.approvehtml(nodeinfo);
        }else{
            html = ' <div class="node-wrap" id="parent_node_wrap" style="min-width:100%;">' +
                '<div class="'+classname+'">\n' +
                '<div class="end-node-text">'+arrJsPopLabel['LBL_START']+'<div class="start-node-circle"></div></div>'+
                '    </div>';
        }

        return html;

        /*
        return ' <div class="node-wrap">' +
            '<div class="start_stage">\n' +
            '        <div class="stagecommon stagetitle">'+arrJsPopLabel['LBL_START']+'</div>\n' +
            '        <div class="stagecommon stageicon">\n' +
            '            <div id="start" class="common-advance-icon advance-icon-start" name="btn_addmenu" nodeid="-1" childid="1">\n' +
            '            </div>\n' +
            '        </div>\n' +
            '        <div class="stagecommon stagecontent"></div>\n' +
            '    </div>';

         */
    }

    this.approvehtml = function(nodeinfo) {
        var html='';
        var stepinfo_detail = nodeinfo.nodeinfo;
        var classname = 'normal_stage';
        if(!empty(nodeinfo.classname)){
            classname = nodeinfo.classname;
        }
        var icon_class = 'advance-icon-unfinish';
        var advanceinfo = nodeinfo.advanceinfo;

        if(!empty(advanceinfo) && !empty(advanceinfo.icon_class)){
            icon_class = advanceinfo.icon_class;
        }
        var content_html = '';
        var title_btn_html = '';
        var text_height = 0;
        if(!empty(advanceinfo)){
            classname += ' ' +advanceinfo.line_class;
            var time_key_arr = ['advancebtn','userfullname','changedon','staytimecontent','taskhtml'];
            var height_arr = [32,20,40,20,0];
            var tag = '';
            var tmp_key = '';
            var tmp_class = '';
            for(var i =0;i<time_key_arr.length;i++){
                tmp_key = time_key_arr[i];
                if(tmp_key == 'taskhtml'){
                    tag = 'advance_task';
                }else{
                    tag = 'advance_text';
                }
                //判断推进按钮是否显示
                if(tmp_key == 'advancebtn'){
                    if(advanceinfo.showbtn == 'yes'){
                        if(advanceinfo.cur_flag == 'yes'){
                            content_html += '<div tag="child_text_height" ><input name="pushbutton" tag="1" class="ld-button ld-button-primary" type="button" value="'+arrJsPopLabel['ADVANCE']+'" onclick="detailbutton_click(this,\''+popupobj.module+'\',\'Advance\',\''+popupobj.record+'\');" /></div>';
                        }else{
                            content_html += '<div tag="child_text_height" style="height: '+height_arr[i]+'px;" ></div>';
                        }
                        text_height += height_arr[i];
                    }
                }else if(!empty(advanceinfo[tmp_key])){
                    if(['userfullname','changedon','staytimecontent'].includes(tmp_key)){
                        tmp_class = 'advance_font_style'
                    }else{
                        tmp_class = '';
                    }

                    content_html += '<div tag="child_text_height" class="'+tmp_class+'"  >';
                    if(tmp_key == 'staytimecontent'){
                        if(!empty(this.module_advacne) && this.module_advacne.showadvancelog != 'no'){
                            content_html += '<b onclick="CrmPopup.getPopupObj(\'last\').AdvanceStageobj.ShowAdvanceDetail(\''+stepinfo_detail.stagevalue+'\');" data-tip="'+arrJsPopLabel['SHOWADVANCEDETAIL']+'" class="icon-homeimg icon-askgrey-help tip-items-list"></b>';
                            content_html += '<span name="showstaytimecontent" stagename="'+stepinfo_detail.stagevalue+'" >'+advanceinfo[tmp_key]+'</span></div>';
                        }else{
                            title_btn_html = '<b onclick="CrmPopup.getPopupObj(\'last\').AdvanceStageobj.ShowAdvanceDetail(\''+stepinfo_detail.stagevalue+'\');" data-tip="'+arrJsPopLabel['SHOWADVANCEDETAIL']+'" class="icon-homeimg icon-askgrey-help tip-items-list"></b>';
                            content_html += '</div>';
                        }
                    }else{
                        content_html += advanceinfo[tmp_key]+'</div>';
                    }

                    text_height += height_arr[i];
                }
            }
        }
        //用于计算任务区域高度
        var height_html = '';
        //带tag的表示要用于计算推进节点和下方的高度差，用于显示详情信息，本来打算写死高度，但是考虑到高度调整的情况，这里只做一个计算参考，实际的高度另外获取
        if(text_height >0)height_html = ' tag="advance_text_height" text_height="'+text_height+'" ';
        var title_html = '<span class="tip-items-list advance_font_style" data-tip="'+stepinfo_detail.stagevalue+'" >'+stepinfo_detail.stagevalue+'</span>';

        if(nodeinfo.nodeid == -1){
            title_btn_html = '<b data-tip="'+arrJsPopLabel['STAGEVALUEISINCORRECT']+'" class="icon-homeimg icon-askgrey-help tip-items-list" style="cursor: default;margin-left: 2px;"></b>';
        }
        title_html = title_btn_html+title_html;

        html=' <div class="node-wrap">' +
            '<div class="'+classname+'" '+height_html+' >\n' +
            '        <div class="stagecommon stagetitle">'+title_html+'</div>\n' +
            '        <div class="stagecommon stageicon" tag="stageicon">\n' +
            '            <div id="start" class="common-advance-icon '+icon_class+'" name="btn_addmenu" childid="'+ld.trim(nodeinfo.childid)+'"  nodeid="'+nodeinfo.nodeid+'">\n' +
            '            </div>\n' +
            '        </div>\n' +
            '        <div class="stagecommon stagecontent" tag="stagecontent">'+content_html+
            '       </div>\n' +
            '    </div>'+
            '</div>';
        return html;
    }

    this.conditionhtml = function(nodeinfo, htmltype) {
        var html = '';
        if(htmltype=='left')
        {
            html = '<div class="col-box back-color-white" style="">'+
                '<div class="top-left-cover-line back-color-white"></div>'+
                '<div class="bottom-left-cover-line back-color-white"></div>'+
                '<div class="condition-node">'+
                '<div class="node-wrap" style="flex: 0;"><div class="normal_stage" style="min-width: 40px;flex: 0;"></div></div>'+
                '</div>';
        }
        else if(htmltype=='right'){
            html = ' <div class="col-box back-color-white" style="" > '+
                '<div class="condition-node">'+
                '<div class="node-wrap" style="flex: 0;"><div class="normal_stage" style="min-width: 40px;flex: 0;"></div></div>'+
                '</div>'+
                '<div class="top-right-cover-line back-color-white"></div>'+
                '<div class="bottom-right-cover-line back-color-white"></div>';
        }
        else{
            html = '<div class="col-box back-color-white" style="" >'+
                '<div class="condition-node">'+
                '<div class="node-wrap" style="flex: 0;" ><div class="normal_stage" style="min-width: 40px;flex: 0;"></div></div>'+
                '</div>';
        }
        return html;
    }

    this.addconditionnodehtml = function(nodeinfo) {
        //虚拟节点
        var classname = 'normal_stage';
        var width = 40;
        if(!empty(nodeinfo.classname)){
            classname = nodeinfo.classname;
            if(classname == 'end_stage'){
                width = 20;
            }
        }

        if(classname == 'end_stage'){
            var html = '<div class="node-wrap" style="flex: 0;"><div class="normal_stage" style="min-width: '+width+'px;flex: 0;"></div></div>';
            html += '<div class="end-node" style="min-width: max-content;">' +
                '<div class="end-node-circle"></div>' +
                '<div class="end-node-text">' + arrJsPopLabel['endworkflow'] + '</div>' +
                '</div>';
        }else{
            var html = '<div class="node-wrap" style="flex: 0;"><div class="'+classname+'" style="min-width: '+width+'px;flex: 0;"></div></div>';
        }
        return html;
        /*
        return '<div class="add-node-btn-box" style="width: 10px;">' +
            '<div class="add-node-btn" "></div></div>';*/
    }
    this.endhtml = function() {
        //流程结束
        if(this.showtype == 'detail'){
            return  '';
        }

        return '<div class="end-node">' +
            '<div class="end-node-circle"></div>' +
            '<div class="end-node-text">' + arrJsPopLabel['endworkflow'] + '</div>' +
            '</div>';
    }

    this.setparenthtml = function (parent_obj){
        var parenthtml = '';
        //流程图主要显示区域
        var mainbox_html = '<div id="approveflow-design-box" class="approveflow-design-box" style="height:100%;overflow: auto;width: 100%;">\n' +
            '<div class="box-scale" name="nodelist" style="transform: scale(1); transform-origin: 50% 0px 0px;min-width:100%;padding: 10px;" >\n' +
            '</div>\n' +
            '</div>';
        parenthtml += mainbox_html;
        //点击选择菜单
        var menu_html = '<div style="position: absolute; top: 0px; left: 0px; width: 100%;display: none;" name="dv_menu">\n' +
            '        <div>\n' +
            '            <div class="ant-popover add-node-wrapper ant-popover-placement-rightBottom " style="left: 975px; top: 148px; transform-origin: -2px 0px;">\n' +
            '                <div class="ant-popover-content">\n' +
            '                    <div class="ant-popover-inner" role="tooltip">\n' +
            '                        <div class="ant-popover-inner-content">\n' +
            '                            <div class="add-node-popover">\n' +
            '                                <div class="add-node-popover-body">\n' +
            '                                    <a class="add-node-popover-item approver" name="btn_addapprover">\n' +
            '                                        <div class="item-wrapper">\n' +
            '                                            <span class="iconfont"></span>\n' +
            '                                        </div>\n' +
            '                                        <span>'+this.label_arr.STEP+'</span>\n' +
            '                                    </a>\n' +
            '                                    <a class="add-node-popover-item route" name="btn_addconditionbranch">\n' +
            '                                        <div class="item-wrapper">\n' +
            '                                            <span class="iconfont"></span>\n' +
            '                                        </div>\n' +
            '                                        <span>'+this.label_arr.ConditionBranch+'</span>\n' +
            '                                    </a>\n' +
            '                                </div>\n' +
            '                            </div>\n' +
            '                        </div>\n' +
            '                    </div>\n' +
            '                </div>\n' +
            '            </div>\n' +
            '        </div>\n' +
            '    </div>';
        parenthtml += menu_html;
        parent_obj.html(parenthtml);
    }

}

cls_advance_node_preview.load = function (popupobj,advanceobj) {
    AjaxJSPage('cls_common_process_js','include/js/modules/process/cls_common_process.js');
    cls_advance_node_preview.prototype = new cls_common_process(popupobj);
    cls_advance_node_preview.prototype.constructor = cls_advance_node_preview;
    var nodeobj = new cls_advance_node_preview(popupobj,advanceobj);
    return nodeobj;
}