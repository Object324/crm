function cls_common_process(popupobj) {
    AjaxJSPage('cls_process_ConditionHtml_js','include/js/modules/process/cls_process_ConditionHtml.js');
    AjaxJSPage('cls_process_StepHtml_js','include/js/modules/process/cls_process_StepHtml.js');
    AjaxJSPage('cls_StepConditionSet.js','include/js/modules/process/cls_StepConditionSet.js');
    //说明：childid 表示该节点有哪些子 节点，branchnodeid：表示该节点的所属分支ID branchnodeid:主要用户分支流程使用
    //设置父节点的目的是用于判断虚拟节点的所属分支

    this.stepflowhtml = '';
    this.laststepindex = 0;
    this.stepflow_arr = [];
    this.label_arr = [];
    //this.conditionlabelindex=1;
    this.maxnodeid = 0;
    this.clickbtnmenuobj; //点击弹出菜单按钮的 圆圈按钮对象 或者点击黄色框审批步骤
    this.conditionvirtual = 'conditionvirtual';
    this.popupobj = popupobj;
    this.module = '';
    this.showtype = '';

    this.setlabelarr = function (){
        var labelbol_arr = [
            'BASICINFORMATION',//基本信息
            'CURRENTSTAGE',//当前阶段
            'addcondition',//添加条件
            'ConditionBranch',//条件分支
            'endworkflow',//流程结束
            'STEPNAME',//步骤名称
            'STEP',//步骤
            'SETSTEPINFORMATION'//请设置步骤信息
        ];
        for (var i = 0;i<labelbol_arr.length;i++){
            this.label_arr[labelbol_arr[i]] = arrJsPopLabel[labelbol_arr[i]];
        }
    }
    this.setlabelarr();
    this.setshowtype = function (showtype){
        this.showtype = showtype;
    }


    this.show = function() {
        var that = this;
        if (that.stepflowhtml == '') {
            var approveid = newApproveSetObj.approveid;
        } else {
            var approveid = 0;
        }

        ldAjax("index.php?module=Settings&action=SettingsAjax&file=newApproveStepFlow&approveid=" + approveid + "&frommodule=" + newApproveSetObj.module, {}, function(ajaxdata) {
            DelProgressObjs();
            ld("#" + that.popupobj.divid + "_scroll").html(ajaxdata.result.content);
            that.label_arr = ajaxdata.result.label;
            that.module = newApproveSetObj.module;

            if (that.stepflowhtml == '') {
                that.stepflow_arr = ajaxdata.result.stepflowlist;
                that.getMaxStepid();
            }

            that.innerNodeHtml();

        })

    }
    this.setparenthtml = function (parent_obj){
        var parenthtml = '';
        //流程图主要显示区域
        var mainbox_html = '';
        if(this.showtype != 'preview'){
            mainbox_html +=  '<div class="zoom" style="right: 6%;">\n' +
                '        <div class="zoom-out" zoomtype="out" name="btn_zoom"></div>\n' +
                '        <span name="zoomvalue">100%</span>\n' +
                '        <div class="zoom-in" zoomtype="in" name="btn_zoom"></div>\n' +
                '    </div>';
        }

        if(this.showtype == 'preview'){
            var hover_style = 'pointer-events: none;';
        }else{
            var hover_style = '';
        }
        mainbox_html+= '<div id="approveflow-design-box" class="approveflow-design-box" style="height:100%;overflow: auto;width: 100%;">\n' +
            '<div class="box-scale" name="nodelist" style="transform: scale(1); transform-origin:0px 50% 0px;'+hover_style+'" >\n' +
            '</div>\n' +
            '</div>';
        parenthtml += mainbox_html;
        //点击选择菜单
        var menu_html = '<div style="position: absolute; top: 0px; left: 0px; width: 100%;display: none;" name="dv_menu">\n' +
            '        <div>\n' +
            '            <div class="ant-popover add-node-wrapper ant-popover-placement-rightBottom " style="left: 975px; top: 148px; transform-origin: -2px 0px;box-shadow: 0px 2px 10px 0px rgb(17 31 44 / 8%);">\n' +
            '                <div class="ant-popover-content">\n' +
            '                    <div class="ant-popover-inner" role="tooltip">\n' +
            '                        <div class="ant-popover-inner-content">\n' +
            '                            <div class="add-node-popover">\n' +
            '                                <div class="add-node-popover-body">\n' +
            '                                    <a class="add-node-popover-item approver" name="btn_addapprover">\n' +
            '                                        <div class="" style="margin: 0 5px;">\n' +
            '                                            <div class="advance-icon-addstep"></div>\n' +
            '                                        </div>\n' +
            '                                        <span>'+this.label_arr.STEP+'</span>\n' +
            '                                    </a>\n' +
            '                                    <a class="add-node-popover-item route" name="btn_addconditionbranch">\n' +
            '                                        <div class="" style="margin: 0 5px;">\n' +
            '                                            <div class="advance-icon-addcondition"></div>\n' +
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

    this.showprocess = function(stepflow_arr) {
        if(empty(stepflow_arr)){
            stepflow_arr = this.get_default_arr();
        }


        this.stepflow_arr = stepflow_arr;
        this.getMaxStepid();

        this.innerNodeHtml();
    }

    this.showemptyprocess = function (){
        this.stepflow_arr = [];
        this.getMaxStepid();
        this.innerNodeHtml();
    }

    this.innerNodeHtml = function() {
        var that = this;

        that.stepflowhtml = '';
        //console.log(that.stepflow_arr);
        if(that.stepflow_arr.length >0){
            that.createhtml(-1, that.stepflow_arr);
            that.stepflowhtml += that.endhtml(); //审批结束
        }

        ld("#" + that.popupobj.divid + " [name=nodelist]").html(that.stepflowhtml);


        if(this.showtype == 'preview'){
            that.setbtnhide();
        }else{
            that.popupobj.center();
            that.setEvent();
            that.showafter();
        }

    }
    this.getMaxStepid = function() {
        var that = this;
        this.maxnodeid = 0;
        for (var i = 0; i < that.stepflow_arr.length; i++) {
            if (parseInt(that.stepflow_arr[i].nodeid) > this.maxnodeid) {
                this.maxnodeid = parseInt(that.stepflow_arr[i].nodeid);

            }
        }

    }

    //根据菜单主键id生成菜单列表html
    //id：菜单childid
    //arry：菜单数组信息
    this.createhtml = function(childid, arry) {
        var that = this;
        if (childid == '' || childid == ',')
            return '';
        var childArry = this.GetChildArry(childid, arry);

        if (childArry.length > 0) {


            var len = childArry.length;
            if (childArry[0].nodetype == 'condition') {
                //添加条件
                this.stepflowhtml += '<div class="branch-wrap">' +
                    '<div class="branch-box-wrap">' +
                    '<div class="branch-box">';
                this.stepflowhtml += '<button class="add-branch" name="btn_addcondition" nodeid=' + childArry[0].nodeid + '>' + this.label_arr.addcondition + '</button>';

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
    this.virtualstepindex = 0;
    this.getVirtualStepindex = function(nodeid) {
        //获取子节点的虚拟节点
        var that = this;

        ld.each(that.stepflow_arr, function(tmpindex, tmpstepinfo) {
            if (tmpstepinfo.branchnodeid == nodeid && tmpstepinfo.nodetype == that.conditionvirtual) {
                that.virtualstepindex = tmpindex
                return false;


            }

        })
        return that.virtualstepindex;


    }
    //根据菜单主键id获取下级菜单
    //childnodeid：菜单主键id
    //arry：菜单数组信息
    this.GetChildArry = function(childnodeid, arry) {
        childnodeid = childnodeid + "";
        var newArry = childnodeid.split(",");
        var newlen = newArry.length;
        var tmparr = [];
        var otherarr = {};

        for (var i in arry) {

            if (arry[i].nodetype == this.conditionvirtual)
                continue; //虚拟节点
            if (newArry.includes(arry[i].nodeid + "")) {
                otherarr[arry[i].nodeid] = arry[i];
                if (newlen == 1) {
                    //只有一个子节点
                    break;
                }
            }
        }
        //将获取到的子步骤信息重新排序
        for (var j = 0; j < newlen; j++) {
            if (!empty(otherarr[newArry[j]])) {
                tmparr.push(otherarr[newArry[j]]);
            }
        }
        return tmparr;
    }
    //duan 20230809 复制时获取子节点应该需要包括虚拟节点
    this.GetChildArryWithvirtual = function(childnodeid, arry) {
        childnodeid = childnodeid + "";
        var newArry = childnodeid.split(",");
        var newlen = newArry.length;
        var tmparr = [];
        var otherarr = {};

        for (var i in arry) {

            if (newArry.includes(arry[i].nodeid + "")) {
                otherarr[arry[i].nodeid] = arry[i];
                if (newlen == 1) {
                    //只有一个子节点
                    break;
                }
            }
        }
        //将获取到的子步骤信息重新排序
        for (var j = 0; j < newlen; j++) {
            if (!empty(otherarr[newArry[j]])) {
                tmparr.push(otherarr[newArry[j]]);
            }
        }
        return tmparr;
    }
    this.starthtml = function(nodeinfo) {

        return ' <div class="node-wrap" id="parent_node_wrap">' +

            '<div class="node-wrap-box node_sid-startevent start-node">' +
            '<div>' +
            '<div class="title" style="">' +
            '<span class="">' + arrJsPopLabel['LBL_START'] + '</span>' +
            '</div>' +
            '<div class="content">' +
            '<div class="text">' + 'start' + '</div>' +
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

    this.approvehtml = function(nodeinfo) {
        //if(this.approverhtmlobj==undefined)

        //getScriptBackWithURL('include/js/modules/process/cls_ApproverHtml.js',function(){
        //同步加载
        var obj = new cls_process_StepHtml();
        obj.setStepInfo(nodeinfo)



        //});

        return obj.gethtml();

    }

    this.conditionhtml = function(nodeinfo, htmltype) {
        //if(this.conditionhtmlobj==undefined)

        //getScriptBackWithURL('include/js/modules/process/cls_ConditionHtml.js',function(){
        //同步加载
        var obj = new cls_process_ConditionHtml();

        //});
        obj.setStepInfo(nodeinfo);

        return obj.gethtml(htmltype);
    }

    this.addconditionnodehtml = function(nodeinfo) {
        //虚拟节点
        return '<div class="add-node-btn-box">' +
            '<div class="add-node-btn"><button class="btn" type="button" value="虚拟节点' + nodeinfo.nodeid + '" name="btn_addmenu" childid="' + nodeinfo.childid + '" nodeid="' + nodeinfo.nodeid + '">' +
            '<span class="iconfont"></span></button></div><div></div></div>';
    }
    this.endhtml = function() {
        //流程结束
        return '<div class="end-node">' +
            '<div class="end-node-circle"></div>' +
            '<div class="end-node-text">' + this.label_arr.endworkflow + '</div>' +
            '</div>'
    }




    this.getFlowStepIndex = function(nodeid) {
        //获取指定节点索引
        var that = this;
        var childindex = '';
        ld.each(that.stepflow_arr, function(tmpindex, tmpinfo) {
            if (tmpinfo.nodeid == nodeid) {
                childid = tmpinfo.childid;
                childindex = tmpindex
                return false;
            }
        })

        return childindex;
    }
    this.branchchild_arr = [];
    this.lastbranchchildindex = -1;
    this.getBranchChild = function(clickflowstepindex, parentvirtualstepinfo) {
        var that = this;
        //获取指定节点的子节点包括儿子 ，孙子，重孙 等等 子子孙孙
        that.lastbranchchildindex = -1;
        that.branchchild_arr = [];


        that.reCyclegetBranchChild(that.stepflow_arr[clickflowstepindex].childid, parentvirtualstepinfo);

    }
    this.reCyclegetBranchChild = function(childidnodeid, parentvirtualstepinfo) {
        var that = this;
        var childid_arr = that.GetChildArryWithvirtual(childidnodeid, that.stepflow_arr);

        for (var i = 0; i < childid_arr.length; i++) {

            if (childid_arr[i].nodeid == parentvirtualstepinfo.nodeid) {
                return;
            } else {
                this.branchchild_arr.push(childid_arr[i]);
                that.reCyclegetBranchChild(childid_arr[i].childid, parentvirtualstepinfo);
            }
        }
    }


    this.getBranchLastChildStepIndex = function(clicknodeid, branchnodeid) {
        //表示点击的节点
        //获取分支节点最后一个子节点 所在的索引
        var that = this;
        that.lastbranchchildindex = -1;
        var havebranchstep = 'no';
        for (var i = that.stepflow_arr.length - 1; i >= 0; i--) {
            if (that.stepflow_arr[i].branchnodeid == branchnodeid) {
                havebranchstep = 'yes';
                if (that.stepflow_arr[i].nodetype == that.conditionvirtual) {
                    //虚拟节点

                    var findnodeid = that.reCyclegetlastVirtualChildBranchIndex(that.stepflow_arr[i].nodeid, that.stepflow_arr[i].nodeid);
                    that.lastbranchchildindex = that.getFlowStepIndex(findnodeid);
                    break;
                }


            }
        }

        if (that.lastbranchchildindex == -1 && havebranchstep == 'yes') {
            //表示分支没有虚拟节点
            var flowstepindex = that.getFlowStepIndex(clicknodeid);

            var findnodeid = that.reCyclegetlastChildBranchnodeid(clicknodeid, that.stepflow_arr[flowstepindex].childid, branchnodeid);

            that.lastbranchchildindex = that.getFlowStepIndex(findnodeid);
        } else if (havebranchstep == 'yes') {

            var findnodeid = that.reCyclegetlastChildBranchnodeid(findnodeid, that.stepflow_arr[that.lastbranchchildindex].childid, findnodeid);

            that.lastbranchchildindex = that.getFlowStepIndex(findnodeid);
        }


        return that.lastbranchchildindex;

    }
    this.reCyclegetlastVirtualChildBranchIndex = function(nodeid, branchnodeid) {
        var isfind = 'no';
        var that = this;
        for (var i = that.stepflow_arr.length - 1; i >= 0; i--) {
            if (that.stepflow_arr[i].branchnodeid == branchnodeid) {

                if (that.stepflow_arr[i].nodetype == that.conditionvirtual) {
                    //虚拟节点
                    isfind = 'yes';
                    return that.reCyclegetlastVirtualChildBranchIndex(that.stepflow_arr[i].nodeid, that.stepflow_arr[i].nodeid);

                }

            }
        }
        if (isfind == 'no') {
            return nodeid;
        }

    }
    this.reCyclegetlastChildBranchnodeid = function(nodeid, childnodeid, branchnodeid) {
        var that = this;
        var childid_arr = that.GetChildArry(childnodeid, that.stepflow_arr);


        if (childid_arr.length > 0) {
            for (var i = 0; i < childid_arr.length; i++) {
                if (childid_arr[i].branchnodeid != branchnodeid) {
                    return nodeid;
                } else {

                    return that.reCyclegetlastChildBranchnodeid(childid_arr[i].nodeid, childid_arr[i].childid, branchnodeid);
                }
            }
        } else {
            return nodeid;
        }
    }
    //获取分支节点的虚拟节点
    this.getbranchlastvirtualnode = function(branchnodeid) {
        var that = this;
        var lastbranchchildindex = -1;
        for (var i = that.stepflow_arr.length - 1; i >= 0; i--) {
            if (that.stepflow_arr[i].branchnodeid == branchnodeid && that.stepflow_arr[i].nodetype == that.conditionvirtual) {
                lastbranchchildindex = i;
                break;
            }
        }


        return lastbranchchildindex;
    }
    this.changebranchnodeid = function(oldstepid, newstepid, menutype) {
        var that = this;
        //修改节点所属分支节点
        //menutype:点击的添加条件分支还是点击的添加审批人
        ld.each(that.stepflow_arr, function(tmpindex, tmpstepinfo) {
            if (tmpstepinfo.branchnodeid == oldstepid) {
                if (menutype == 'approver' && that.stepflow_arr[tmpindex].nodetype == that.conditionvirtual) {
                    //如果添加的审批则不需要修改虚拟的节点的parentstepid
                } else if (that.stepflow_arr[tmpindex].nodetype == 'start') {

                } else
                    that.stepflow_arr[tmpindex].branchnodeid = newstepid
            }

        })
    }
    this.changechildId = function(nodeid, newchildid) {
        var that = this;
        var childid = '';
        var tmparr = [];
        ld.each(that.stepflow_arr, function(tmpindex, tmpinfo) {
            if (tmpinfo.nodeid == nodeid) {
                childid = tmpinfo.childid;
                that.stepflow_arr[tmpindex].childid = newchildid;
                return false;
            }
        })


    }

    this.setEvent = function() {

        var that = this;
        var btn_addapproverobj = ld("#" + that.popupobj.divid + " [name=btn_addapprover]"); //添加审批按钮
        ld(btn_addapproverobj).unbind("click").bind("click", function() {
            //添加审批人
            that.maxnodeid++;

            var nodeid = ld(that.clickbtnmenuobj).attr("nodeid");
            var childid = ld(that.clickbtnmenuobj).attr("childid");

            that.changechildId(nodeid, that.maxnodeid + ""); //修改当前节点的子节点为审批人节点
            var branchnodeid = nodeid;
            var curstepindex = that.getFlowStepIndex(nodeid); //获取点击节点的索引
            if (that.stepflow_arr[curstepindex].nodetype == 'approver') {
                branchnodeid = that.stepflow_arr[curstepindex].branchnodeid;
            }
            var nodeinfo = {
                "id": '',
                'nodeid': that.maxnodeid + "",
                'nodename': that.label_arr['STEP'] + that.maxnodeid,
                nodetype: 'approver',
                'childid': childid + "",
                'branchnodeid': branchnodeid,
                'nodeinfo': []
            };
            nodeinfo['nodeinfo'].nodename = nodeinfo.nodename;
            that.stepflow_arr.push(nodeinfo);


            ld("#" + that.popupobj.divid + " [name=dv_menu]").css("display", 'none')
            that.innerNodeHtml();

        })

        var btn_addconditionbranchobj = ld("#" + that.popupobj.divid + " [name=btn_addconditionbranch]"); //添加条件分支按钮
        ld(btn_addconditionbranchobj).unbind("click").bind("click", function() {
            //添加条件分支

            var nodeid = ld(that.clickbtnmenuobj).attr("nodeid");
            var curstepindex = that.getFlowStepIndex(nodeid); //获取点击节点的索引
            var curflowstepinfo = that.stepflow_arr[curstepindex];

            var curchildstepid = curflowstepinfo.childid;

            if (that.stepflow_arr[curstepindex].nodetype == 'approver') {
                var lastchildstepindex = that.getBranchLastChildStepIndex(nodeid, curflowstepinfo.branchnodeid); //获取分支节点的最后一个节点索引
            } else
                var lastchildstepindex = that.getBranchLastChildStepIndex(nodeid, nodeid); //获取分支节点的最后一个节点索引

            var flowvirtualstepid = that.maxnodeid + 3; //虚拟节点
            flowvirtualstepid += "";
            var branchnodeid = nodeid; //点击虚拟节点，或条件步骤 或开始步骤
            if (curflowstepinfo.nodetype == 'approver') //点击审批人
            {
                branchnodeid = curflowstepinfo.branchnodeid;
            }

            var nodeid_1 = that.maxnodeid + 1;
            var flowstepinfo_1 = {
                'id': '',
                'nodeid': nodeid_1 + "",
                'nodename': "条件" + nodeid_1,
                nodetype: 'condition',
                'childid': flowvirtualstepid,
                'branchnodeid': branchnodeid,
                'nodeinfo': []
            };
            flowstepinfo_1['nodeinfo'].nodename = flowstepinfo_1.nodename;
            var nodeid_2 = that.maxnodeid + 2;
            var flowstepinfo_2 = {
                'id': '',
                'nodeid': nodeid_2 + "",
                'nodename': "条件" + nodeid_2,
                nodetype: 'condition',
                'childid': flowvirtualstepid,
                'branchnodeid': branchnodeid,
                'nodeinfo': []
            };
            flowstepinfo_2['nodeinfo'].nodename = flowstepinfo_2.nodename;
            var flowvirtualstepinfo = {
                'id': '',
                'nodeid': flowvirtualstepid + "",
                'nodename': "虚拟节点" + flowvirtualstepid,
                nodetype: that.conditionvirtual,
                'childid': "",
                'branchnodeid': branchnodeid
            };

            //改变当前节点的子节点为条件1 和条件2
            that.changechildId(nodeid, nodeid_1 + "," + nodeid_2);

            if (lastchildstepindex <= 0 || lastchildstepindex == curstepindex) {
                flowvirtualstepinfo.childid = curchildstepid; //修改虚拟节点的子节点为当前节点的子节点
                that.stepflow_arr.push(flowstepinfo_1);
                that.stepflow_arr.push(flowstepinfo_2);
                that.stepflow_arr.push(flowvirtualstepinfo);
            } else {

                var lastchildstepinfo = that.stepflow_arr[lastchildstepindex];

                var lastchildstepid = lastchildstepinfo.nodeid

                //修改条件节点所属分支节点，为条件1

                if (curflowstepinfo.nodetype == 'approver') //点击审批人添加条件分支
                    that.changebranchnodeid(curflowstepinfo.branchnodeid, nodeid_1, 'condition');
                else if (curflowstepinfo.nodetype == 'condition' || curflowstepinfo.nodetype == that.conditionvirtual ||
                    curflowstepinfo.nodetype == 'start') //点击虚拟节点，或条件步骤
                    that.changebranchnodeid(nodeid, nodeid_1, 'condition');

                that.stepflow_arr.push(flowstepinfo_1);
                that.stepflow_arr.push(flowstepinfo_2);
                //虚拟节点
                if (lastchildstepinfo.nodetype != that.conditionvirtual || lastchildstepindex != curstepindex + 1)
                    that.changechildId(nodeid_1, curchildstepid); //条件1的子节点修改为当前节点

                that.stepflow_arr.push(flowvirtualstepinfo);

                if (lastchildstepinfo.childid == '' || lastchildstepinfo.childid == ',') {
                    that.changechildId(lastchildstepid, flowvirtualstepid);
                } else if (lastchildstepinfo.nodetype == 'approver') {
                    that.changechildId(flowvirtualstepid, lastchildstepinfo.childid); //修改虚拟节点的子节点为审批人的子节点
                    //console.log(lastchildstepid);
                    // console.log(flowvirtualstepid);
                    that.changechildId(lastchildstepid, flowvirtualstepid); //

                } else //如果最后一个节点有子节点，则虚拟节点的子节点修改为当前条件流程最后一个节点
                {
                    that.changechildId(flowvirtualstepid, lastchildstepinfo.childid); //修改虚拟节点的子节点为审批人的子节点
                    that.changechildId(lastchildstepid, flowvirtualstepid);
                }
            }


            ld("#" + that.popupobj.divid + " [name=dv_menu]").css("display", 'none')

            that.maxnodeid = parseInt(flowvirtualstepid)

            that.innerNodeHtml();



        })

        var btn_addconditionobj = ld("#" + that.popupobj.divid + " [name=btn_addcondition]"); //添加条件
        ld(btn_addconditionobj).unbind("click").bind("click", function() {
            //添加新条件
            var nodeid = ld(this).attr("nodeid"); //获取的是第一个条件nodeid
            var flowstepindex = that.getFlowStepIndex(nodeid);
            var flowstepinfo = that.stepflow_arr[flowstepindex];
            var parentflowstepindex = that.getparentflowstepindex(nodeid); //获取父节点的索引
            that.maxnodeid++;
            //console.log(that.stepflow_arr[parentflowstepindex]);

            //设置所属父节点 新增一个子节点iD
            var childid_arr = that.stepflow_arr[parentflowstepindex].childid.split(",");
            childid_arr.push(that.maxnodeid);
            that.stepflow_arr[parentflowstepindex].childid = childid_arr.join(",");

            var newflowstepinfo = {};
            ld.each(flowstepinfo, function(key, value) {
                var type = typeof value
                if (type.toLowerCase() != 'object')
                    newflowstepinfo[key] = value;
                else {
                    newflowstepinfo[key] = {};
                }
            })
            newflowstepinfo.nodeid = that.maxnodeid;
            //  newflowstepinfo.nodetype='new';
            //获取所属分支节点的最后一个节点
            var lastchildstepindex = that.getbranchlastvirtualnode(that.stepflow_arr[flowstepindex].branchnodeid); //获取分支节点的虚拟节点的索引
            //console.log(that.stepflow_arr[lastchildstepindex])
            //获取子节点个数
            var childarr = that.GetChildArry(that.stepflow_arr[parentflowstepindex].childid, that.stepflow_arr);
            newflowstepinfo.nodename = "条件" + that.maxnodeid //"条件"+childarr.length;
            newflowstepinfo['nodeinfo'].nodename = newflowstepinfo.nodename; //条件步骤 设置
            newflowstepinfo.id = '';

            newflowstepinfo.childid = that.stepflow_arr[lastchildstepindex].nodeid;
            that.stepflow_arr.push(newflowstepinfo);

            that.innerNodeHtml();
        })
        //为流程界面绑定关闭选择框事件，实现点击选择弹框以外的地方都能关闭弹框
        ld("#" + that.popupobj.divid + " [name=nodelist]").unbind('click').bind('click', function() {
            var dv_menuobj = ld("#" + that.popupobj.divid + " [name=dv_menu]");
            if (dv_menuobj.attr('addmenu') == 'yes') {
                //判断点击添加时不需要隐藏弹框
                dv_menuobj.attr('addmenu', 'no');
            } else if (dv_menuobj.attr('addmenu') == 'no') {
                //弹框出现后，再次点击其他位置则关闭弹框
                dv_menuobj.hide();
                dv_menuobj.attr('addmenu', '');
            }
        })
        var btn_addmenuobj = ld("#" + that.popupobj.divid + " [name=btn_addmenu]"); //弹出添加菜单 (圆圈按钮)
        ld(btn_addmenuobj).unbind("click").bind("click", function() {
            //添加

            that.clickbtnmenuobj = ld(this);

            var left = parseInt(ld(this).offset().left);
            var width = parseInt(ld(this).css('width'));
            var top = parseInt(ld(this).offset().top);

            var scrolltop = parseInt(ld("#" + that.popupobj.divid + "_scroll").find(" .HorizontalProcess-design").scrollTop());
            var scrollleft = parseInt(ld("#" + that.popupobj.divid + "_scroll").find(" .HorizontalProcess-design").scrollLeft());

            ld("#" + that.popupobj.divid + " [name=dv_menu]").find(" .ant-popover").css("left", (scrollleft + left + width + 30) + "px")
            ld("#" + that.popupobj.divid + " [name=dv_menu]").find(" .ant-popover").css("top", (top + scrolltop -10) + "px")
            ld("#" + that.popupobj.divid + " [name=dv_menu]").show();
            ld("#" + that.popupobj.divid + " [name=dv_menu]").attr('addmenu', 'yes');
            //ld("#"+that.popupobj.divid+"_scroll").find(" .approveflow-design").scrollTop(parseInt(ld("#"+that.popupobj.divid).css("height")))
        })


        ld("#" + that.popupobj.divid + " [name=btn_copy]").unbind("click").bind("click", function() {

            //拷贝流程步骤
            var nodeid = ld(this).attr('nodeid');

            var flowstepindex = that.getFlowStepIndex(nodeid);
            var parentflowstepindex = that.getparentflowstepindex(nodeid);
            var parentvirtualnodeindex = that.getbranchlastvirtualnode(that.stepflow_arr[flowstepindex].branchnodeid);
            if (parentvirtualnodeindex == -1) {
                //没有虚拟节点
                //nodeid,childnodeid,branchnodeid
                //获取最后一代节点的nodeid
                var lastnodeid = that.reCyclegetlastChildBranchnodeid(nodeid, that.stepflow_arr[flowstepindex].childid, that.stepflow_arr[flowstepindex].branchnodeid);
                var lastbranchindex = that.getFlowStepIndex(lastnodeid);
                var parentvirtualnodeindex = that.getFlowStepIndex(that.stepflow_arr[lastbranchindex].childid.split(',')[0]);

            }

            var parentvirtualstepinfo = that.stepflow_arr[parentvirtualnodeindex];
            //获取需要拷贝的节点
            that.getBranchChild(flowstepindex, parentvirtualstepinfo);
            that.branchchild_arr.unshift(that.stepflow_arr[flowstepindex]);
            //newflowstep 的branchnodeid修改

            var newflowstep_arr = [];
            var havechangenodeid_arr = [];
            ld.each(that.branchchild_arr, function(tmpbrachindex, tmpbranchstepinfo) {

                var newflowstepinfo = {};

                ld.each(tmpbranchstepinfo, function(key, value) {
                    var type = typeof value
                    if (type.toLowerCase() != 'object')
                        newflowstepinfo[key] = value;
                    else {
                        newflowstepinfo[key] = {}; //nodeinfo
                        ld.each(value, function(tmpkey, tmpvalue) {
                            type = typeof tmpvalue
                            if (tmpvalue != 'object')
                                newflowstepinfo[key][tmpkey] = tmpvalue;
                            else {
                                newflowstepinfo[key][tmpkey][tmp_key] = {}; //高级查询
                                ld.each(tmpvalue, function(tmp_key, tmp_value) {
                                    newflowstepinfo[key][tmpkey][tmp_key] = tmpvalue;
                                })
                            }
                        })
                    }
                })
                if (havechangenodeid_arr[tmpbranchstepinfo.nodeid + "aa"] == undefined) {
                    //如果当前节点，没有被修改节点ID
                    that.maxnodeid++;
                    havechangenodeid_arr[newflowstepinfo.nodeid + "aa"] = that.maxnodeid;
                    newflowstepinfo.nodeid = that.maxnodeid;
                } else {
                    newflowstepinfo.nodeid = havechangenodeid_arr[tmpbranchstepinfo.nodeid + "aa"]
                }
                var childid_arr = newflowstepinfo.childid.split(',');
                var newchildid_arr = [];

                if (that.GetChildArryWithvirtual(newflowstepinfo.childid, that.branchchild_arr).length <= 0) {
                    //最后一代节点，不需要修改子节点的ID
                } else {
                    for (var j = 0; j < childid_arr.length; j++) {
                        //如果该子节点已经新建过对应的节点，则不重复获取
                        if (empty(havechangenodeid_arr[childid_arr[j] + "aa"])) {
                            that.maxnodeid++;
                            havechangenodeid_arr[childid_arr[j] + "aa"] = that.maxnodeid;
                            newchildid_arr.push(that.maxnodeid);
                        } else {
                            newchildid_arr.push(havechangenodeid_arr[childid_arr[j] + "aa"]);
                        }
                    }
                    newflowstepinfo.childid = newchildid_arr.join(",");
                }
                newflowstepinfo.id = '';
                newflowstepinfo.nodename = newflowstepinfo.nodename + "(复制)";
                //没有设置过信息的审批步骤增加默认stepinfo对象
                if (empty(newflowstepinfo.nodeinfo) || newflowstepinfo.nodeinfo == undefined) newflowstepinfo.nodeinfo = {};
                if(that.showtype == 'advance_edit' && newflowstepinfo.nodetype == 'approver'){
                    newflowstepinfo.nodeinfo = {};
                }
                newflowstepinfo.nodeinfo.nodename = newflowstepinfo.nodename;
                if (tmpbrachindex == 0)
                    that.stepflow_arr[parentflowstepindex].childid += "," + newflowstepinfo.nodeid;

                that.stepflow_arr.push(newflowstepinfo);
                newflowstep_arr.push(newflowstepinfo);

            })
            ld.each(newflowstep_arr, function(tmpindex, tmpinfo) {
                if (tmpindex > 0) {
                    //改变新节点的branchnodeid
                    if (havechangenodeid_arr[tmpinfo.branchnodeid + "aa"] != undefined)
                        tmpinfo.branchnodeid = havechangenodeid_arr[tmpinfo.branchnodeid + "aa"]
                    else
                        tmpinfo.branchnodeid = newflowstep_arr[0].branchnodeid;
                }

            })

            that.innerNodeHtml();

        })
        var btn_delflowstepobj = ld("#" + that.popupobj.divid + " [name=btn_delflowstep]");
        ld(btn_delflowstepobj).unbind("click").bind("click", function() {
            //删除步骤
            var nodeid = ld(this).attr('nodeid');
            var curflowstepindex = that.getFlowStepIndex(nodeid); //获取删除节点的索引
            var curflowstepinfo = that.stepflow_arr[curflowstepindex];
            //判断流程是否在使用中
            if (that.approveused == 'yes') {
                var curstepid = curflowstepinfo['id'];
                if (curstepid > 0) {
                    var confirm_str = arrJsPopLabel['PROCESSUSEDCANOTDELETED2'];
                    RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", confirm_str);
                    return false;
                }
            }

            var parentflowstepindex = that.getparentflowstepindex(nodeid); //获取删除节点的复节点

            if (that.stepflow_arr[curflowstepindex].nodetype == 'approver') {
                //删除审批人
                that.stepflow_arr[parentflowstepindex].childid = curflowstepinfo.childid;
                that.stepflow_arr.splice(curflowstepindex, 1);

            } else {

                //获取同级条件数组
                var parentflowstepinfo = that.stepflow_arr[parentflowstepindex];
                var childarr = that.GetChildArry(parentflowstepinfo.childid, that.stepflow_arr);
                var childnodeid_arr = [];
                for (var i = 0; i < childarr.length; i++) {
                    childnodeid_arr.push(childarr[i].nodeid);

                }
                var childindex = childnodeid_arr.indexOf(nodeid);
                childnodeid_arr.splice(childindex, 1);
                that.stepflow_arr[parentflowstepindex].childid = childnodeid_arr.join(",");
                //删除条件节点
                that.delConditionStep(nodeid, curflowstepinfo.branchnodeid);

                if (childnodeid_arr.length == 1) {
                    //如果只有一个条件了，则剩余的一个条件也删除

                    childarr.splice(childindex, 1);

                    var delflowstepindex = that.getFlowStepIndex(childarr[0].nodeid);
                    var branchnodeid = childarr[0].branchnodeid; //所属分支ID


                    parentflowstepinfo.childid = that.stepflow_arr[delflowstepindex].childid;
                    that.stepflow_arr.splice(delflowstepindex, 1);


                    //所属分支的虚拟节点索引,一定会有虚拟分支节点
                    var virtualstepindex = that.getbranchlastvirtualnode(curflowstepinfo.branchnodeid);

                    //获取虚拟节点的父节点
                    var parentvirturalflowstepindex = that.getparentflowstepindex(that.stepflow_arr[virtualstepindex].nodeid);

                    //改变虚拟节点的父节点的childid
                    that.stepflow_arr[parentvirturalflowstepindex].childid = that.stepflow_arr[virtualstepindex].childid;
                    that.stepflow_arr.splice(virtualstepindex, 1); //删除虚拟节点

                    //改变剩余的最后一个条件的分支节点的所属分支节点
                    that.changebranchnodeid(childarr[0].nodeid, childarr[0].branchnodeid);

                }
            }



            that.innerNodeHtml();
            //删除步骤

        })


        var btn_changeconditionobj = ld("#" + that.popupobj.divid + " [name=btn_changecondition]");
        //更改条件的优先级
        ld(btn_changeconditionobj).unbind("click").bind("click", function() {


            var changetype = ld(this).attr("changetype");
            var curnodeid = ld(this).attr("nodeid");
            var curflowstepindex = that.getFlowStepIndex(curnodeid);
            var curflowstepinfo = that.stepflow_arr[curflowstepindex];

            var parentflowstepindex = that.getparentflowstepindex(curnodeid);
            var childid_arr = that.stepflow_arr[parentflowstepindex].childid.split(",");

            if (changetype == 'right') {

                var nextnodeid;
                for (var i = 0; i < childid_arr.length; i++) {
                    if (childid_arr[i] == curnodeid) {
                        nextnodeid = childid_arr[i + 1]
                        childid_arr[i] = childid_arr[i + 1];
                        childid_arr[i + 1] = curnodeid;

                        break;
                    }
                }
                var nextflowstepindex = that.getFlowStepIndex(nextnodeid);

                that.stepflow_arr[curflowstepindex] = that.stepflow_arr[nextflowstepindex]
                that.stepflow_arr[nextflowstepindex] = curflowstepinfo;

            } else if (changetype == 'left') {

                var prevnodeid;
                for (var i = 0; i < childid_arr.length; i++) {
                    if (childid_arr[i] == curnodeid) {
                        prevnodeid = childid_arr[i - 1]
                        childid_arr[i] = childid_arr[i - 1];
                        childid_arr[i - 1] = curnodeid;
                        break;
                    }
                }
                var prevflowstepindex = that.getFlowStepIndex(prevnodeid);
                that.stepflow_arr[curflowstepindex] = that.stepflow_arr[prevflowstepindex]
                that.stepflow_arr[prevflowstepindex] = curflowstepinfo;
            }
            that.stepflow_arr[parentflowstepindex].childid = childid_arr.join(",");

            that.innerNodeHtml();

            //调换条件位置 优先级
        })

        var btn_zoomobj = ld("#" + that.popupobj.divid + " [name=btn_zoom]");
        ld(btn_zoomobj).unbind("click").bind("click", function() {
            //放大缩小
            that.zoom(ld(this).attr("zoomtype"))
        })

        var btn_setapproverstepobj = ld("#" + that.popupobj.divid + " [name=btn_setapproverstep]");
        ld(btn_setapproverstepobj).parent().unbind("click").bind("click", function() {
            //修改审批人信息
            var obj;
            var nodeid = ld(this).find('[name=btn_setapproverstep]').attr('nodeid');

            that.ShowNodePopup(nodeid);

        })



        ld("#" + that.popupobj.divid + " [name=btn_setcondition]").unbind("click").bind("click", function() {
            //设置审批条件
            var obj;
            var nodeid = ld(this).attr('nodeid');
            var curflowstepindex = that.getFlowStepIndex(nodeid);


            //getScriptBackWithURL('include/js/modules/Approve/cls_StepConditionSet.js',function(){
            //同步加载
            obj = new cls_StepConditionSet(nodeid, that);

            //});
            obj.show();

        })

        ld("#" + that.popupobj.divid + " [name=btn_prev]").unbind("click").bind("click", function() {
            //上一步
            newApproveSetObj.showapproveinfo();
        })
        //审批保存
        ld("#" + that.popupobj.divid + " [name=btn_approvesave]").unbind('click').bind("click", function() {
            //测试完成保存后，把newApproveSetObj.approvedatainfo_arr 的属性值finishedallowedit变空才保存
            //console.log(that.stepflow_arr);
            //console.log(JSON.stringify(that.stepflow_arr));
            var param = {
                "approveinfo": JSON.stringify(newApproveSetObj.approvedatainfo_arr),
                'nodeinfo': JSON.stringify(that.stepflow_arr)
            };

            ldAjax('index.php?module=Settings&action=SettingsAjax&file=newApproveSave&approveid=' + newApproveSetObj.approveid + "&tabid=" + newApproveSetObj.tabid, param, function(ajaxdata) {
                DelProgressObjs();
                if (ajaxdata.code == -1) {
                    RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", ajaxdata.msg);
                    return;
                }
                that.popupobj.CancelEvent();
                getCustomBlockList(ld("#pick_module").get(0), '', '');

            })
        })

        //设置事件函数
    }
    this.zoom = function(zoomtype) {
        //放大缩小
        var that = this;
        var scale = 10;
        var zoomvalue = ld("#" + that.popupobj.divid + " [name=zoomvalue]").html().substr(0, ld("#" + that.popupobj.divid + " [name=zoomvalue]").html().length - 1);


        if (zoomtype == 'out') {
            if (parseInt(zoomvalue) <= 50) {
                return;
            }
            zoomvalue = parseInt(zoomvalue) - scale;
        } else {
            if (parseInt(zoomvalue) >= 300) {
                return;
            }
            zoomvalue = parseInt(zoomvalue) + scale;
        }
        scale = parseFloat((zoomvalue / 100)).toFixed(1);
        ld("#" + that.popupobj.divid + " [name=zoomvalue]").html(zoomvalue + "%")

        ld("#" + that.popupobj.divid + " [name=nodelist]").get(0).style.transform = "scale(" + scale + ")";
    }
    //删除条件节点和子节点，但是不删除所属分支的虚拟节点

    this.delConditionStep = function(nodeid, branchnodeid) {

        nodeid = nodeid + "";
        var newArry = nodeid.split(",");
        var newlen = newArry.length;
        var child_arr = [];
        var that = this;

        for (var i in that.stepflow_arr) {

            if (that.stepflow_arr[i].nodetype == that.conditionvirtual && that.stepflow_arr[i].branchnodeid == branchnodeid) {
                continue;
            }
            if (newArry.includes(that.stepflow_arr[i].nodeid + "")) {
                child_arr.push(that.stepflow_arr[i]);

                if (newlen == 1) {
                    //只有一个子节点
                    break;
                }


            }
        }

        if (child_arr.length > 0) {
            // console.log(child_arr[0].nodeid)
            for (var i in child_arr) {
                if (child_arr[i].nodeid == undefined)
                    continue;
                var flowstepindex = that.getFlowStepIndex(child_arr[i].nodeid);
                that.stepflow_arr.splice(flowstepindex, 1);
                that.delConditionStep(child_arr[i].childid, branchnodeid);

            }
        } else {
            return;
        }
    }
    this.getparentflowstepindex = function(childnodeid) {
        //获取父节点的索引
        childnodeid = childnodeid + '';
        var parentflowstepindex = -1;
        var childid_arr = [];
        ld.each(this.stepflow_arr, function(tmpindex, tmpinfo) {
            childid_arr = tmpinfo.childid.split(',');
            if (childid_arr.includes(childnodeid)) {
                parentflowstepindex = tmpindex;
                return false;
            }
        })
        return parentflowstepindex;
    }
    //点击节点弹出层方法(公共文件里留个空方法继承)
    this.ShowNodePopup = function (nodeid){
        var that = this;
        var curflowstepindex = that.getFlowStepIndex(nodeid); //获取删除节点的索引
        var curflowstepinfo = that.stepflow_arr[curflowstepindex];

        var crmpopupobj=CrmPopup.load(curflowstepinfo.nodename,that.NodePopupSave,"",parseInt(850),this.module,'',arrJsPopLabel['SAVE'],"","");
        crmpopupobj.position=CrmPopup.Positions.right;
        crmpopupobj.setButtonPosition('right');
        crmpopupobj.setHeight(CrmPopup.getClientHeight());
        crmpopupobj.popupMaxHeight=(CrmPopup.getClientHeight())
        crmpopupobj.isclicklayerclose='yes';//点击遮罩层关闭弹出层
        crmpopupobj.prevshow();
        crmpopupobj.OkfunParamObj = [nodeid,crmpopupobj];
        //this.label_arr.NODENAME ,curflowstepinfo.nodename
        var node_html = '<div style="padding: 16px;">\n' +
            '    <div class="first-drawer-content-item">\n' +
            '                <label class="drawer-content-item-title2"><font color="red">*</font>'+this.label_arr.NODENAME+'</label>\n' +
            '                <input class="txt" name="nodename" id="nodename"  type="text" value="'+curflowstepinfo.nodename+'">\n' +
            '    </div>\n' +
            '</div>';

        CrmPopup.setPopupobjHtmlscrolljquery_noposition(crmpopupobj,node_html)
    }
    //通用保存方法
    this.NodePopupSave = function (nodeid,cur_popupobj){
        var that = this;
        var curflowstepindex = that.getFlowStepIndex(nodeid); //获取删除节点的索引

        var nodename = ld('#'+cur_popupobj.divid+ ' #nodename').val();
        if(empty(nodename)){
            MessagePopup.TipZero_warning(that.label_arr.NODENAME+arrJsPopLabel['CANOTEMPTY']);
            return '';
        }
        this.SpecialSave(nodeid,cur_popupobj);

        that.stepflow_arr[curflowstepindex]['nodename'] = nodename;
        cur_popupobj.CancelEvent();
        that.innerNodeHtml();
    }
    //节点信息弹出层预置空方法（留着给其他地方继承）
    this.SpecialSave = function (nodeid,cur_popupobj){

    }

    this.get_default_arr = function (){
        var default_arr = new Array();
        var tmp_start = {id:"",childid:"1",nodetype:'start', nodename:arrJsPopLabel['LBL_START'],branchnodeid:'-1',nodeid:'-1',nodeinfo:[]};
        var first_step = {id:"",childid:"",nodetype:'approver',nodename:arrJsPopLabel['STEP']+'1',branchnodeid:"-1",nodeid:'1',nodeinfo:[]};
        default_arr.push(tmp_start);
        default_arr.push(first_step);
        this.default_arr = default_arr;
        return this.default_arr;
    }
    //页面加载后执行方法,留空等重载
    this.showafter = function (){

    }
    //预览状态隐藏所有操作按钮
    this.setbtnhide = function (){
        //添加节点按钮,删除节点按钮,切换节点按钮,复制节点按钮,添加条件按钮,编辑节点按钮
        var btn_arr = ['btn_addmenu','btn_delflowstep','btn_changecondition','btn_copy','btn_addcondition','btn_setapproverstep'];
        var divobj = ld("#" + this.popupobj.divid)
        for (var i=0;i<btn_arr.length;i++){
            divobj.find('[name='+btn_arr[i]+']').hide();
        }
    }

}