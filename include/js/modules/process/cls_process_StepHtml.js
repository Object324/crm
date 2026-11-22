function cls_process_StepHtml()
{
    var that=this;
    
    this.setStepInfo=function(nodeinfo)
    {
        this.nodeinfo=nodeinfo;
    }
    this.gethtml=function(){
        
        
        
        var html='';
        var approver_label = this.label_arr['SETSTEPINFORMATION'];
        var stepinfo_detail = this.nodeinfo.nodeinfo;
        //显示审批人信息
        if(!empty(stepinfo_detail.approvetype_label)){
        approver_label = arrJsPopLabel['APPROVERTYPEJS']+':'+stepinfo_detail.approvetype_label+'<br>'+stepinfo_detail.approvevalue_label;
        }
        
        html='<div class="node-wrap">'+
            '<div class="node-wrap-box node_sid-startevent">'+
                '<div>'+
                    '<div class="title" style="">'+
                        '<span class="" name="caneditstepname sort-tip-items" title="' +this.nodeinfo.nodename+ '" style="overflow: hidden;white-space: nowrap;text-overflow: ellipsis;">'+this.nodeinfo.nodename+'</span>'+
                        '<span class="title-close" name="btn_delflowstep" nodeid="'+this.nodeinfo.nodeid+'">x</span>'+
                    '</div>'+
                    '<div class="content">'+
                        '<div class="text">'+approver_label+'</div>'+
                        ' <span class="jiantou jiantou_right" name="btn_setapproverstep" nodeid="'+this.nodeinfo.nodeid+'" ></span>'+
                    '</div>'+
                '</div>'+
            '</div>'+
            '<div class="add-node-btn-box">'+
                '<div class="add-node-btn">'+
                    '<button id="start" class="btn" type="button" name="btn_addmenu" childid="'+ld.trim(this.nodeinfo.childid)+'"  nodeid="'+this.nodeinfo.nodeid+'">'+
                        '<span class="iconfont"></span>'+
                    '</button>'+
                '</div>'+
            ' </div>'+
        '</div>';
        return html;
    }
}