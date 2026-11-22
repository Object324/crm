function cls_advance_node(popupobj,advanceobj) {
    this.advanceobj = advanceobj;
    var cu_this = this;

    //点击节点弹出层方法
    this.ShowNodePopup = function (nodeid){
        var advanceobj = this.advanceobj;
        var curflowstepindex = this.getFlowStepIndex(nodeid); //获取删除节点的索引
        var curflowstepinfo = this.stepflow_arr[curflowstepindex];
        var prevpopupobj = this.popupobj;
        var cur_flowobj = this;
        var crmpopupobj=CrmPopup.load(curflowstepinfo.nodename,this.NodePopupSave,"",parseInt(300),advanceobj.modulename,'',"","","");
        crmpopupobj.position=CrmPopup.Positions.right;
        crmpopupobj.setButtonPosition('right');
        crmpopupobj.setHeight(CrmPopup.getClientHeight());
        crmpopupobj.popupMaxHeight=(CrmPopup.getClientHeight())
        crmpopupobj.isclicklayerclose='yes';//点击遮罩层关闭弹出层
        crmpopupobj.prevshow();
        crmpopupobj.OkfunParamObj = [nodeid,crmpopupobj];

        //this.label_arr.NODENAME ,curflowstepinfo.nodename
        var fieldname = ld("#"+prevpopupobj.divid +" #module_field").val();
        var stagevalue = curflowstepinfo.nodeinfo.stagevalue;
        if(empty(stagevalue))stagevalue = '';
        crmpopupobj.fieldname = fieldname;
        crmpopupobj.stagevalue = stagevalue;
        crmpopupobj.module = advanceobj.modulename;

        var surl = 'index.php?module=Settings&action=SettingsAjax&file=AdvanceProcessSet&modulename='+advanceobj.modulename+'&sub_mode=getadvancelist';
        var param = {'fieldname':fieldname,'stagevalue':stagevalue};
        ldAjaxNoProgress(surl,param,function (data){
            var node_html = '<div  style="font-size: 15px;height:'+(CrmPopup.getClientHeight()-50)+'px" ><div style="padding: 16px;">\n' +
                '    <div class="first-drawer-content-item">\n' +
                '                <label class="drawer-content-item-title2"><font color="red">*</font>'+arrJsPopLabel['STEPNAME']+'</label>\n' +
                '                <input class="ld-input-inner" name="nodename" id="nodename"  type="text" value="'+curflowstepinfo.nodename+'">\n' +
                '    </div>\n' +
                '</div>';
            var picklistcontent_arr = advanceobj.picklist_arr[fieldname];

            node_html += '<div name="cur_stagevalue" id="cur_stagevalue" style="padding:0px 16px;" ></div>';

            //设置阶段推进关系
            var advancerelation = data.result.advancerelation;
            var relation_html = '<div id="advance_relation_list" class="ld-advance-relation-list">';

            relation_html += advanceobj.getAdvanceRelationHtml(fieldname,advancerelation,stagevalue,nodeid);

            relation_html +=  '</div>';
            node_html += relation_html;
            //底部按钮显示
            var btn_html = '<div class="E_pbtn" style="width:100%;position:absolute;bottom:0px" id="btn_nodesave_div">\n' +
                '<input name="button" id="btn_nodesave" class="E_pbtnok ld-button ld-button-primary" value="保存" tagclick="" type="button">\n' +
                '</div>';
            node_html += btn_html;
            node_html += '</div>';
            CrmPopup.setPopupobjHtmlscrolljquery_noposition(crmpopupobj,node_html);
            //绑定编辑节点弹出层事件
            advanceobj.bindPopupEvent(nodeid,crmpopupobj,cur_flowobj,fieldname);

        })
    }
    //节点信息弹出层预置保存空方法
    this.NodePopupSave = function (nodeid,cur_popupobj){

        var curflowstepindex = this.getFlowStepIndex(nodeid); //获取删除节点的索引

        var nodename = ld('#'+cur_popupobj.divid+ ' #nodename').val();

        if(empty(nodename)){
            MessagePopup.TipZero_warning(arrJsPopLabel['STEPNAME']+arrJsPopLabel['CANOTEMPTY']);
            return '';
        }
        var stagevalue = cur_popupobj.stagevalue;

        this.stepflow_arr[curflowstepindex]['nodename'] = nodename;
        var nodeinfo = {'stagevalue':stagevalue,'showlabel':stagevalue}
        this.stepflow_arr[curflowstepindex]['nodeinfo'] = nodeinfo;

        cur_popupobj.CancelEvent();
        this.innerNodeHtml();
    }

    this.approvehtml = function(node_arr) {
        var html='';
        var show_label = arrJsPopLabel['SETSTEPINFORMATION'];
        var stepinfo_detail = node_arr.nodeinfo;
        //显示审批人信息
        if(!empty(stepinfo_detail['showlabel'])){
            show_label = arrJsPopLabel['CURRENTSTAGE']+':'+stepinfo_detail['showlabel'];
        }

        html='<div class="node-wrap">'+
            '<div class="node-wrap-box node_sid-startevent" id="child_node_wrap_box" nodeid="'+node_arr.nodeid+'" >'+
            '<div>'+
            '<div class="title" style="">'+
            '<span class="" name="caneditstepname sort-tip-items" title="' +node_arr.nodename+ '" style="overflow: hidden;white-space: nowrap;text-overflow: ellipsis;">'+node_arr.nodename+'</span>'+
            '<span class="title-close" name="btn_delflowstep" nodeid="'+node_arr.nodeid+'">x</span>'+
            '</div>'+
            '<div class="content" name="stagevalue_box"  >'+
            '<div class="text" nodeid="'+node_arr.nodeid+'">'+show_label+'</div>'+
            ' <span class="jiantou jiantou_right" name="btn_setapproverstep" nodeid="'+node_arr.nodeid+'" ></span>'+
            '</div>'+
            '</div>'+
            '</div>'+
            '<div class="add-node-btn-box">'+
            '<div class="add-node-btn">'+
            '<button id="start" class="btn" type="button" name="btn_addmenu" childid="'+ld.trim(node_arr.childid)+'"  nodeid="'+node_arr.nodeid+'">'+
            '<span class="iconfont"></span>'+
            '</button>'+
            '</div>'+
            ' </div>'+
            '</div>';
        return html;
    }

    this.showafter = function (){
        var fieldname = ld("#"+this.popupobj.divid +" #module_field").val();
        this.advanceobj.setPickListContent(fieldname,this.stepflow_arr);
        this.advanceobj.setDragEvent();
    }

    this.setStepvalue = function (nodeid,newvalue){
        var curflowstepindex = this.getFlowStepIndex(nodeid); //获取删除节点的索引
        var stagevalue = decodeURIComponent(newvalue);

        var nodeinfo = {'stagevalue':stagevalue,'showlabel':stagevalue}
        this.stepflow_arr[curflowstepindex]['nodeinfo'] = nodeinfo;

        this.innerNodeHtml();
    }
    //交换两个步骤的信息
    this.stepchangevalue = function (before_nodeid,after_nodeid){
        var before_index = this.getFlowStepIndex(before_nodeid);
        var after_index = this.getFlowStepIndex(after_nodeid);

        var before_nodeinfo = this.stepflow_arr[before_index]['nodeinfo'];
        var after_nodeinfo = this.stepflow_arr[after_index]['nodeinfo'];

        this.stepflow_arr[before_index]['nodeinfo'] = after_nodeinfo;
        this.stepflow_arr[after_index]['nodeinfo'] = before_nodeinfo;
        this.innerNodeHtml();
    }

    this.starthtml = function(nodeinfo) {

        return ' <div class="node-wrap" id="parent_node_wrap">' +

            '<div class="node-wrap-box node_sid-startevent start-node">' +
            '<div>' +
            '<div class="title" style="">' +
            '<span class=""></span>' +
            '</div>' +
            '<div class="content">' +
            '<div class="text">' + arrJsPopLabel['LBL_START'] + '</div>' +
            '<span class="jiantou jiantou_right" style="display:none"></span>' +
            '</div>' +
            '</div>' +
            '</div>' +
            '<div class="add-node-btn-box">' +
            '<div class="add-node-btn">' +
            '<button id="start" class="btn" type="button" name="btn_addmenu" nodeid=-1 childid="' + nodeinfo.childid + '">' +
            '<span class="iconfont"></span>' +
            '</button>' +
            '</div>' +
            '</div>'
    }

}

cls_advance_node.load = function (popupobj,advanceobj) {
    AjaxJSPage('cls_common_process_js','include/js/modules/process/cls_common_process.js');
    cls_advance_node.prototype = new cls_common_process(popupobj);
    cls_advance_node.prototype.constructor = cls_advance_node;
    var nodeobj = new cls_advance_node(popupobj,advanceobj);
    return nodeobj;
}