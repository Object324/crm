function cls_resetComboxHtml(name)
{
    //设置下拉框可以查询
    this.name=ld.trim(name);
    this.popupobj=CrmPopup.getPopupObj("last");
    var that=this;
    that.selectobj=new Object();//select 对象
    this.picklistcontent=[];//edit:can 2020-09-11 下拉框内容
    this.picklistcontentseq=[];//edit:can 2020-09-11 下拉框内容
    this.picklistColors=[];//edit:can 2020-09-11 下拉框内容
    this.pickfieldtype='';//字段是主表还是明细表(producttoolfield,tabdetailfield)
    this.detailrowindex=0;//edit：can 2020-09-17 当是明细字段，明细字段所在的tr的属性rowindex值
    that.picklistcontentlength=0;
    this.trobj=undefined;
    this.width=0;
    this.searchhtmltype='text';
    this.have_related = 'yes';
    this.setPopupObj=function(popupobj)
    {
        that.popupobj=popupobj;
    }
    this.setPickListContent=function(picklistcontent)
    {
        this.picklistcontent=picklistcontent;
    }
    this.setPickListContentseq=function(picklistcontentseq)
    {
        this.picklistcontentseq=picklistcontentseq;
    }
    this.setPickListColors=function(picklistColors)
    {
        this.picklistColors=picklistColors;
    }
    this.setHaveRelated = function (have_related) {
        this.have_related = have_related;
    }
    this.getHaveRelated = function () {
        return this.have_related;
    }
    /* this.setPickFieldType=function(pickfieldtype)
     {
         //字段是主表还是明细表(producttoolfield,tabdetailfield)
         this.pickfieldtype=pickfieldtype;
     }*/
    this.setDetailFieldRowIndex=function(rowindex)
    {
        this.trobj=that.popupobj.getDetailTableObj().find("tr[rowindex="+rowindex+"]");

        this.detailrowindex=rowindex;
    }
    this.setComboxObjHtmlByWidth=function(width){
        this.width=width;
        if(this.name!='')
        {
            var obj=ld("#"+that.popupobj.divid+" [name='"+name+"']");
            if(obj.length>0)
                that.setSearchComboxHtml(obj);
        }
        else
        {
            ld.each(ld("#"+that.popupobj.divid).find("select"),function(){
                that.setSearchComboxHtml(ld(this));
            })
        }
        that.setEvent();
    }

    this.setSearchComboxWidthByhtml=function(obj,width)
    {
        this.width=width;

        this.setSearchComboxHtml(obj);

        that.setEvent();
    }

    this.setComboxObjHtml=function(){

        if(this.name!='')
        {
            var obj=ld("#"+that.popupobj.divid+" [name='"+name+"']");
            if(obj.length>0)
                that.setSearchComboxHtml(obj);
        }
        else
        {
            ld.each(ld("#"+that.popupobj.divid).find("select"),function(){
                that.setSearchComboxHtml(ld(this));
            })
        }
        that.setEvent();
    }
    this.setEvent=function(){

        //edit:can 20210207 044613: 通用问题/需求（kfbcrm）编辑创建自定义字段的时候，选项框展开的情况下，点击页面其他部分不会关闭选项框（详情见附件）如有疑问请艾特我
        ld(document).bind("click",function(){
            ld(" .chzn-drop").css("display",'none');
        })

        if(that.name!='')
        {
            if(that.detailrowindex>0)
            {
                //单据分录字段

                var trobj=that.trobj;
                var dv_cmb_obj=ld(trobj).find("[name='dv_cmb_"+that.name+"']");
            }
            else
                var dv_cmb_obj=ld("#"+that.popupobj.divid).find("[name='dv_cmb_"+that.name+"']");

            var arrowobj=ld(dv_cmb_obj).find(" [tag=arrow]");
            var txt_search_obj=ld(dv_cmb_obj).find("[tag=txt_search]");//下拉框搜索
            //alert(ld(arrowobj).length);
        }
        else
        {
            if(that.detailrowindex>0)
            {
                //单据分录字段
                var trobj=that.trobj;
                var arrowobj=ld(trobj).find(" [tag=arrow]");
                var dv_cmb_obj=ld(trobj).find("[tag=txt_search]");
            }
            else
            {
                var arrowobj=ld("#"+that.popupobj.divid).find(" [tag=arrow]");
                var txt_search_obj=ld("#"+that.popupobj.divid).find("[tag=txt_search]");//下拉框搜索
            }
        }
        if(that.detailrowindex>0)
            ld(txt_search_obj).addClass("dropdown-toggle tip-items Bornone");
        // var livalueobj=ld("#"+that.popupobj.divid).find(" [tag=livalue]");//点击赋值
        ld(txt_search_obj).unbind("click").bind("click",function(event){
            var tmpobj=ld(this);
            if(that.detailrowindex>0)
            {
                //单据分录下拉框

                var cur_value=ld(that.trobj).find(" [name='cmb_span_optiontext_"+that.name+"']").val();
                ld(that.trobj).find(" [name='cmb_span_optiontext_"+that.name+"']").val("").focus().val(cur_value);
            }
            else
            {
                var cur_value=ld("#"+that.popupobj.divid+" [name='cmb_span_optiontext_"+that.name+"']").val();
                ld("#"+that.popupobj.divid+" [name='cmb_span_optiontext_"+that.name+"']").val("").focus().val(cur_value);
            }

        });

        if(that.detailrowindex>0)
        {


            ld(txt_search_obj).first().focus(function(){

                var fieldinfo=that.popupobj.detailfieldcolumninfo[that.name];
                if(empty(fieldinfo)){
                    return true;
                }
                var label=commonLabels.CtrlEnterComBox.replace("[varfield]",fieldinfo.fieldlabel);
                label=label.replace("[varfield]",fieldinfo.fieldlabel);

                ld("#"+that.popupobj.divid+' [name=detailCtrlEnterComBox]').html(label);
                ld("#"+that.popupobj.divid+' [name=detailCtrlEnterComBox]').show();
            });
            ld(txt_search_obj).blur(function(){
                ld("#"+that.popupobj.divid+' [name=detailCtrlEnterComBox]').hide();
                //ld(this).find(" [detailcolumnname="+that.name+"]").val(value);
            })
        }

        ld(txt_search_obj).unbind("keyup").bind("keyup",function(event){
            var tmpobj=ld(this);
            var e = event || window.event
            var keyCode = e.keyCode || e.which || e.charCode;
            var ctrlKey = e.ctrlKey || e.metaKey;

            //var tmptrobj= that.popupobj.getTrObjByChild(txt_search_obj);
            that.detailrowindex=ld(that.trobj).attr("rowindex");
            if(ctrlKey && (keyCode==13||keyCode==10)&&that.detailrowindex>0)
            {
                //拖动换行有问题，所以此处重新获取detailrowindex

                //CTRl+ENTER
                //var value= ld(that.trobj).find("[detailcolumnname="+that.name+"]").val();
                var value='';
                var text=ld(that.trobj).find(" [name='cmb_span_optiontext_"+that.name+"']").val();
                var trobjs=that.popupobj.getTrObjsByDelType('no');
                var ulobj=ld(that.trobj).find(" [name='cmb_ul_"+that.name+"']");
                ld.each(ld(ulobj).find("li"),function(){
                    if(ld.trim(ld(this).html())==text)
                    {
                        value=ld(this).attr("value");
                        return false;
                    }
                })

                ld.each(trobjs,function(){
                    var attrrowindex=ld(this).attr("rowindex");

                    if(parseInt(attrrowindex)>parseInt(that.detailrowindex))
                    {

                        ld(this).find(" #"+that.name).val(value);
                        ld(this).find(" [name='cmb_span_optiontext_"+that.name+"']").val(text);
                        that.getSpecialRelatedData(attrrowindex,that.name,value);
                    }
                })

                StopEvent(event);

            }
            else if(ctrlKey)
            {

            }
            else if(keyCode==13)
            {
            }
            else
                getJsScript('include/js/multipingyin.js',function(){

                    that.makePys(event,tmpobj,that.name);
                });
            //BUG0064731 edit:hzx 20230413
            //重新计算下拉框位置
            that.arrowobjkeyup(arrowobj);
        })
        ld(arrowobj).unbind("click").bind("click",function(event){
            //注意：如果下拉框内容是通过ld_related_producttoolfield，设置，则该函数不有可能不再调用

            // BUG0069258 可搜索下拉框 判断重新点击关闭下拉框
            var tmpfldname=ld(arrowobj).attr("dropdownname");
            var dv_drop_obj=ld("#"+that.popupobj.divid+" [name='dv_drop_"+tmpfldname+"']");
            if(dv_drop_obj.get(0).style.display == 'none'){
                that.arrowobjClick(arrowobj);
            }else{
                dv_drop_obj.css('display','none');
            }

        })


    }
    //BUG0064731 edit:hzx 20230413
    //重新计算下拉框位置
    this.arrowobjkeyup = function(arrowobj){
        var tmpfldname=ld(arrowobj).attr("dropdownname");
        var browserheight=parseInt(CrmPopup.getClientHeight());//浏览器的高度
        if(that.detailrowindex>0)
        {

            var trobj=that.trobj;
            var left=ld(trobj).find(" [name='dv_chzn_"+tmpfldname+"']").offset().left;
            var obj=ld(trobj).find(" [name='"+tmpfldname+"']");
            var tmpwidth=parseInt(ld(trobj).find(" [name='dv_chzn_"+tmpfldname+"']").css("width"));

            var dropheight=parseInt(ld(trobj).find(" [name='dv_drop_"+tmpfldname+"']").css("height"));//下拉内容的高度
            var chznheight =ld("#"+that.popupobj.divid+" [name='dv_chzn_"+tmpfldname+"']").get(0).clientHeight;//wym BUG0071210 kfbcrm-高级查找下拉框，太靠上
            currenTop=ld(trobj).find(" [name='dv_chzn_"+tmpfldname+"']").offset().top+chznheight;
            var  marginbottom=browserheight-ld(trobj).find(" [name='dv_chzn_"+tmpfldname+"']").offset().top-dropheight;
            var dv_drop_obj=ld(trobj).find(" [name='dv_drop_"+tmpfldname+"']");
            dv_drop_obj.css('display','block');
        }
        else
        {
            var left=ld("#"+that.popupobj.divid+" [name='dv_chzn_"+tmpfldname+"']").offset().left;
            var obj=ld("#"+that.popupobj.divid+" [name='"+tmpfldname+"']");
            var tmpwidth=parseInt(ld("#"+that.popupobj.divid+" [name='dv_chzn_"+tmpfldname+"']").css("width"));

            var dropheight=parseInt(ld("#"+that.popupobj.divid+" [name='dv_drop_"+tmpfldname+"']").css("height"));//下拉内容的高度
            var chznheight =ld("#"+that.popupobj.divid+" [name='dv_chzn_"+tmpfldname+"']").get(0).clientHeight;
            currenTop=ld("#"+that.popupobj.divid+" [name='dv_chzn_"+tmpfldname+"']").offset().top+chznheight;
            var  marginbottom=browserheight-ld("#"+that.popupobj.divid+" [name='dv_chzn_"+tmpfldname+"']").offset().top-dropheight;

            var dv_drop_obj=ld("#"+that.popupobj.divid+" [name='dv_drop_"+tmpfldname+"']");
            dv_drop_obj.css('display','block');
        }


        if(marginbottom>0)
        {

            ld(dv_drop_obj).css("top",currenTop);
        }
        else{
            //edit:can 2020-08-31 42547: 朗捷账套->价格管理->客户报价单：单据分录下拉框看不全
            //zkt 2021-12-06 0049121: （81mis.com/kfbcrm/index.php）客户》新增》搜索“上海灵当信息科技有限公司”，工商查询后设置回填字段，“参保人数 ”和其下面的字段，搜索字段名显示界面乱，示图
            ld(dv_drop_obj).css("top",currenTop-dropheight-chznheight);
        }
    }
    this.arrowobjClick=function(arrowobj){

        ld(" .chzn-drop").css("display",'none');
        var tmpfldname=ld(arrowobj).attr("dropdownname");
        //edit:can 2020-09-18 42700: （61mis.com/kfbcrm）合同订单模块>新建单据界面：单据分录中的下拉框，点开了，如果不选择，没法关掉这个下拉框的弹出层
        StopEvent(event);
        if(that.detailrowindex>0)
        {
            //edit:can 20210412 45428: （https://61mis.com/kfbcrm [^]）新建出库单时，多选产品之后，使用ctrl+enter键更改多行仓库字段的数据，但是没有生效
            ld(that.trobj).find("[name='txt_search_"+that.name+"']").focus();
            ld(that.trobj).find(" [name='cmb_span_optiontext_"+that.name+"']").select();
        }
        else
        {
            CrmPopup.findHtmlobj(that.popupobj.divid,"txt_search_"+that.name).focus();
            CrmPopup.findHtmlobj(that.popupobj.divid,"cmb_span_optiontext_"+that.name).select();
        }
        //下拉框内容
        that.setPickListHtml(tmpfldname);

        var browserheight=parseInt(CrmPopup.getClientHeight());//浏览器的高度
        if(that.detailrowindex>0)
        {

            var trobj=that.trobj;
            var left=ld(trobj).find(" [name='dv_chzn_"+tmpfldname+"']").offset().left;
            var obj=ld(trobj).find(" [name='"+tmpfldname+"']");
            var tmpwidth=parseInt(ld(trobj).find(" [name='dv_chzn_"+tmpfldname+"']").css("width"));

            var dropheight=parseInt(ld(trobj).find(" [name='dv_drop_"+tmpfldname+"']").css("height"));//下拉内容的高度
            var chznheight =ld("#"+that.popupobj.divid+" [name='dv_chzn_"+tmpfldname+"']").get(0).clientHeight;//wym BUG0071210 kfbcrm-高级查找下拉框，太靠上
            currenTop=ld(trobj).find(" [name='dv_chzn_"+tmpfldname+"']").offset().top+chznheight;
            var  marginbottom=browserheight-ld(trobj).find(" [name='dv_chzn_"+tmpfldname+"']").offset().top-ld(trobj).find(" [name='dv_chzn_"+tmpfldname+"']").outerHeight()-dropheight-chznheight;//BUG0067439 火狐底部计算不够
            var dv_drop_obj=ld(trobj).find(" [name='dv_drop_"+tmpfldname+"']");

        }
        else
        {
            var left=ld("#"+that.popupobj.divid+" [name='dv_chzn_"+tmpfldname+"']").offset().left;
            var obj=ld("#"+that.popupobj.divid+" [name='"+tmpfldname+"']");
            var tmpwidth=parseInt(ld("#"+that.popupobj.divid+" [name='dv_chzn_"+tmpfldname+"']").css("width"));

            var dropheight=parseInt(ld("#"+that.popupobj.divid+" [name='dv_drop_"+tmpfldname+"']").css("height"));//下拉内容的高度
            var chznheight =ld("#"+that.popupobj.divid+" [name='dv_chzn_"+tmpfldname+"']").get(0).clientHeight;
            currenTop=ld("#"+that.popupobj.divid+" [name='dv_chzn_"+tmpfldname+"']").offset().top+chznheight;
            var  marginbottom=browserheight-ld("#"+that.popupobj.divid+" [name='dv_chzn_"+tmpfldname+"']").offset().top-ld("#"+that.popupobj.divid+" [name='dv_chzn_"+tmpfldname+"']").outerHeight()-dropheight;

            var dv_drop_obj=ld("#"+that.popupobj.divid+" [name='dv_drop_"+tmpfldname+"']");

        }

        if(marginbottom>0)
        {

            ld(dv_drop_obj).css("top",currenTop);
        }
        else{
            //edit:can 2020-08-31 42547: 朗捷账套->价格管理->客户报价单：单据分录下拉框看不全
            //zkt 2021-12-06 0049121: （81mis.com/kfbcrm/index.php）客户》新增》搜索“上海灵当信息科技有限公司”，工商查询后设置回填字段，“参保人数 ”和其下面的字段，搜索字段名显示界面乱，示图
            ld(dv_drop_obj).css("top",currenTop-dropheight-chznheight);
        }
        ld(dv_drop_obj).css("display",'');

        ld(dv_drop_obj).css("left",left);
    }

    this.makePys=function(event,txt_searchjqueryobj,tmpfldname){
        if(this.detailrowindex>0) {
            var tableobj=this.popupobj.getDetailTableObj();
            var trobj=ld(tableobj).find("tr[rowindex="+this.detailrowindex+"]");
            var obj=ld(trobj).find(" [name='"+tmpfldname+"']");
        } else
            var obj=ld("#"+that.popupobj.divid+" [name='"+tmpfldname+"']");
        if(ld(obj).prop("tagName").toLocaleLowerCase()=='select')
        {   //使用下拉框搜索


            com_chosen(event,tmpfldname,that.popupobj.divid);

            return ;
        }
        var searchobj=ld(txt_searchjqueryobj).get(0);//查询文本框
        if(searchobj==undefined) {
            return false;
        }
        var divid=that.popupobj.divid;
        //obj.val('');//ctrl+Enter
        if(this.searchhtmltype=='text')
            var searchtext=searchobj.value;
        else
            var searchtext=ld(searchobj).html();
        searchtext=searchtext.replace(/<br>/ig,'');
        var uppersearch=searchtext.toLowerCase();
        var b=false;
        var j=0;
        var pingyin=false;
        var li_chzn_obj=undefined;
        var findpycount=0;
        var selectvalue='';
        var text = '';
        var value = '';
        //duan 20240528 因为下拉框顺序调整,导致数组顺序跟下拉框顺序不同,导致模糊匹配错误,先修改成按元素获取
        if(that.detailrowindex>0) {
            var li_chzn_objs=ld(trobj).find(" [name='dv_drop_"+tmpfldname+"']").find('li');
        } else {
            var li_chzn_objs=CrmPopup.findHtmlobj(divid,'dv_drop_'+tmpfldname).find('li');
        }
        ld.each(li_chzn_objs,function(){
            li_chzn_obj = ld(this);
            if(li_chzn_obj.length <=0){
                return true;
            }
            text = li_chzn_obj.html();
            value = text;
            if(li_chzn_obj.attr('value') != undefined){
                value = li_chzn_obj.attr('value');
            }
            text=(text+"").toLowerCase();
            text=text.replace(/&nbsp;/ig, "");
            var arrRslt = makePy(text);
            if(arrRslt != undefined){
                var pingyingstr=arrRslt.join("").toLowerCase();
                if(text.indexOf(uppersearch)>=0||pingyingstr.indexOf(uppersearch)>=0||uppersearch=='') {
                    b=true;
                    findpycount++;
                    ld(li_chzn_obj).attr("class","");
                    ld(li_chzn_obj).addClass('active-result');
                    selectvalue=value;
                } else {
                    ld(li_chzn_obj).attr("class","");
                }
            }
        })

        /*
        ld.each(that.picklistcontent,function(text,value){
            var text=(text+"").toLowerCase();
            text=text.replace(/&nbsp;/ig, "");
            var arrRslt = makePy(text);
            if(arrRslt != undefined){
                var pingyingstr=arrRslt.join("").toLowerCase();
                if(that.detailrowindex>0) {
                    li_chzn_obj=ld(trobj).find(" [name='dv_chzn_"+j+"_"+tmpfldname+"']");
                } else {
                    li_chzn_obj=CrmPopup.findHtmlobj(divid,'dv_chzn_'+j+"_"+tmpfldname);
                }
                if(text.indexOf(uppersearch)>=0||pingyingstr.indexOf(uppersearch)>=0||uppersearch=='') {
                    b=true;
                    findpycount++;
                    ld(li_chzn_obj).attr("class","");
                    ld(li_chzn_obj).addClass('active-result');
                    selectvalue=value;
                } else {
                    ld(li_chzn_obj).attr("class","");
                }
                j++;
            }
        });
         */
        if(b==false) {
            if(that.detailrowindex>0)
                var  li_chzn_obj= ld(trobj).find(" [name='li_chzn_"+tmpfldname+"']");
            ld(li_chzn_obj).attr("class","");
            ld(li_chzn_obj).addClass("active-result");
        } else {
            if(findpycount==1) {
                ld(trobj).find("#"+tmpfldname).val(selectvalue);
            }
            if(that.detailrowindex>0)
                var  li_chzn_obj= ld(trobj).find(" [name='li_chzn_"+tmpfldname+"']");
            ld(li_chzn_obj).attr("class","");
        }
    }

    this.clearSelectedText=function(tmpfldname)
    {
        ld(that.trobj).find(" #"+tmpfldname).val('');
        if(this.searchhtmltype=='text')
            ld(that.trobj).find(" [detailcolumnname='cmb_span_optiontext_"+tmpfldname+"']").val('');
        else
            ld(that.trobj).find(" [detailcolumnname='cmb_span_optiontext_"+tmpfldname+"']").html('');
    }
    this.removeAllLi=function(tmpfldname)
    {
        var ulobj=ld(that.trobj).find(" [name='cmb_ul_"+tmpfldname+"']");
        ulobj.find("li").remove();
    }
    this.setPickListHtml=function(tmpfldname)
    {

        //下拉框内容填充
        var trobj=that.trobj;
        that.detailrowindex=ld(trobj).attr("rowindex");

        if(that.detailrowindex>0)
        {
            var obj=ld(trobj).find(" [name='"+tmpfldname+"']");
            var ulobj=ld(trobj).find(" [name='cmb_ul_"+tmpfldname+"']");
        }
        else
        {
            var obj=ld("#"+that.popupobj.divid+" [name='"+tmpfldname+"']");
            var ulobj=ld("#"+that.popupobj.divid+" [name='cmb_ul_"+tmpfldname+"']");
        }
        var livalueobj=ld(ulobj).find(" [tag=livalue]");//点击赋值

        if(ld(livalueobj).length<=0)
        {
            var comboxhtml='';
            var index=0;
            var index_groups=0;
            that.picklistcontentlength=0;
            ld(ulobj).html('');
            if(ld(obj).prop("tagName").toLocaleLowerCase()=='select')
            {
                var child=ld(obj).children();
                ld.each(child,function(){
                    childTagName = ld(this).prop('tagName').toLocaleLowerCase();
                    if(childTagName=='option'){
                        var text = ld(this).text();
                        var value = ld(this).val();
                        var color = ld(this).attr('pickcolor');
                        comboxhtml += '  <li  style="color:' + color + ';" class="active-result" tag="livalue" groups="'+tmpfldname+'_optgroups_'+index_groups+'" name="dv_chzn_'+index+'_' + tmpfldname + '" value="' + value + '" dropdownname="' + tmpfldname + '"  onmouseover="cmb_limouseover(event,\'' + tmpfldname + '\')">' + text + '</li>';
                        index++;
                    }else if(childTagName=='optgroup'){
                        var label = ld(this).attr('label');
                        comboxhtml += '  <li class="active-result" name="'+tmpfldname+'_optgroups_'+index_groups+'" data-groupindex="'+index_groups+'" title="'+label+'" style="cursor: default;" ><strong style="font-size: 14px;">'+label+'</strong></li>';
                        var options=ld(this).find('option');
                        ld.each(options, function () {
                            var text = ld(this).text();
                            var value = ld(this).val();
                            //zxm 2021-0621 单据分录的下拉框字段 设置颜色
                            var color = ld(this).attr('pickcolor');
                            comboxhtml += '  <li  style="color:' + color + ';padding-left: 20px;" class="active-result" tag="livalue" groups="'+tmpfldname+'_optgroups_'+index_groups+'" name="dv_chzn_' + index + '_' + tmpfldname + '" value="' + value + '" dropdownname="' + tmpfldname + '"  onmouseover="cmb_limouseover(event,\'' + tmpfldname + '\')">' + text + '</li>';
                            index++;
                        });
                    }
                    index_groups++;
                });
            }
            else
            {
                var picklistcontent=that.picklistcontent;
                var picklistcontentseq=that.picklistcontentseq;
                var picklistColors=that.picklistColors;
                if(picklistcontentseq != undefined && picklistcontentseq.length >0){
                    ld.each(picklistcontentseq,function(tmindex,text){
                        var value = picklistcontent[text];
                        var color =picklistColors[value];
                        comboxhtml+='  <li  style="color:'+color+'" class="active-result" tag="livalue" name="dv_chzn_'+index+'_'+tmpfldname+'" value="'+value+'" dropdownname="'+tmpfldname+'"  onmouseover="cmb_limouseover(event,\''+tmpfldname+'\')">'+text+'</li>';
                        index++;
                    })
                }
                else{
                    ld.each(picklistcontent,function(text,value){
                        var color =picklistColors[value];
                        comboxhtml+='  <li  style="color:'+color+'" class="active-result" tag="livalue" name="dv_chzn_'+index+'_'+tmpfldname+'" value="'+value+'" dropdownname="'+tmpfldname+'"  onmouseover="cmb_limouseover(event,\''+tmpfldname+'\')">'+text+'</li>';
                        index++;
                    })
                }
            }
            comboxhtml += '<li style="" class="" name="li_chzn_'+tmpfldname+'"> '+arrJsPopLabel['NOMATCHINGITEMS']+'</li>';
            ld(ulobj).html(comboxhtml);

            //zxm 20221117 分录冻结列导致下拉框看不到  分录字段且固定定位时候 才
            if(that.detailrowindex>0){
                var objtd = Tools.getParentobjByChild(ulobj,'td');//zxm 20221117 下拉框所在的td父级
                var tdposition = objtd.css('position');
                if(tdposition=='sticky'){
                    that.setDropDivFixed(ulobj,tmpfldname);
                }
            }




            livalueobj=ld(ulobj).find(" [tag=livalue]");//点击赋值
            ld(livalueobj).unbind("click").bind("click",function(){

                var tmpfldname=ld(this).attr("dropdownname");
                ld("#"+that.popupobj.divid+" [name='dv_drop_"+tmpfldname+"']").css("display",'none');


                that.cmb_liclick(ld(this),tmpfldname);


                CrmPopup.findHtmlobj(that.popupobj.divid,"cmb_span_optiontext_"+tmpfldname).attr('cur_input_select',"no");

            })
        }
        else{
            // ld(livalueobj)
        }


    }
    //zxm 20221117 分录冻结列导致下拉框看不到
    this.setDropDivFixed = function(ulobj,tmpfldname){
        var trobj=that.trobj;
        var objtr = Tools.getParentobjByChild(ulobj,'tr');//zxm 20221117 冻结列导致下拉框看不到 下拉框所在的tr父级
        var objtd = Tools.getParentobjByChild(ulobj,'td');//zxm 20221117 下拉框所在的td父级
        var objdivdrop = trobj.find("[name='dv_drop_"+tmpfldname+"']");
        var tmptop = objtd.offset().top;
        tmptop = parseInt(tmptop) +3;
        var tmpleft = objtd.offset().left;
        var tmpwidth = trobj.find("[name='dv_chzn_"+tmpfldname+"']").width();
        tmpwidth = parseInt(tmpwidth) +3;
        objtr.append('<div class="chzn-container" id="freezedv_drop_'+tmpfldname+'"></div>');
        objtr.find('#freezedv_drop_'+tmpfldname).append(objdivdrop);
        //zxm 20230505 注释以下一行	BUG0064092	kfbcrm 费用报销单---分录“费用类别”---选择值后，框内文字左侧有空白
        // objtd.attr('align','right');
        objdivdrop.css('position','fixed').show().css('top',tmptop+'px').css('width',tmpwidth+'px').css('left',tmpleft+'px');
    }
    this.cmb_liclick=function(liobj,fldname)
    {
        // var e = event || window.event;
        //window.event? window.event.cancelBubble = true : e.stopPropagation();

        var divid=that.popupobj.divid;
        var trobj=that.trobj;

        var optionvalue=ld(liobj).attr('value');

        if(that.detailrowindex>0)
        {
            if(that.popupobj.RelatedProductToolFieldtriggcols != undefined)
                that.popupobj.RelatedProductToolFieldtriggcols[that.detailrowindex] = [fldname];
            var objoption=ld(trobj).find(" [name='"+fldname+"']");
        }
        else
            var objoption=CrmPopup.findHtmlobj(divid,fldname);

        objoption.val(optionvalue);
        var optiontext=ld(liobj).text();
        optiontext = that.setOptionText(optiontext);
        var tmpcolor = ld(liobj).css('color');

        if(that.detailrowindex>0)
        {
            //单据分录字段
            ld(trobj).find(" [name='cmb_a_"+fldname+"']").attr("class","");
            ld(trobj).find(" [name='cmb_a_"+fldname+"']").attr("class",'chzn-single');

            if(this.searchhtmltype=='text')
                ld(trobj).find(" [name='cmb_span_optiontext_"+fldname+"']").val(optiontext);
            else
                ld(trobj).find(" [name='cmb_span_optiontext_"+fldname+"']").html(optiontext);

            ld(trobj).find(" [name='cmb_span_optiontext_"+fldname+"']").attr('cur_input_select',"no");
            ld(trobj).find("[name='dv_drop_"+fldname+"']").css("left",ld(liobj).attr("dvleft")+"px");//隐藏下拉框

            //zxm 20230519 BUG0066736 分录下拉框点击选中之后 没有显示颜色的bug
            if(that.popupobj.detailfieldmodule=='Products')
            {

                that.popupobj.detaildatavalue_arr[that.detailrowindex-1][fldname]=optiontext;
            }
            ld(trobj).find(" [name='cmb_span_optiontext_"+fldname+"']").css('color',tmpcolor);
            /// ld(trobj).find(" [name='cmb_span_optiontext_"+fldname+"']").focus();
        }
        else
        {
            CrmPopup.findHtmlobj(divid,"cmb_a_"+fldname).attr("class","");
            CrmPopup.findHtmlobj(divid,"cmb_a_"+fldname).attr("class",'chzn-single');
            if(this.searchhtmltype=='text')
                CrmPopup.findHtmlobj(divid,'cmb_span_optiontext_'+fldname).val(optiontext);
            else
                CrmPopup.findHtmlobj(divid,'cmb_span_optiontext_'+fldname).html(optiontext);
            CrmPopup.findHtmlobj(that.popupobj.divid,"cmb_span_optiontext_"+fldname).attr('cur_input_select',"no");
            ld("#"+that.popupobj.divid+" [name='dv_drop_"+fldname+"']").css("left",ld(liobj).attr("dvleft")+"px");//隐藏下拉框
            ld("#"+that.popupobj.divid+" [name='cmb_span_optiontext_"+fldname+"']").css('color',tmpcolor);
        }
        //67740:企业微信服务合同（QYWXHT-338），合同金额与 收款不一致  ,双向绑定数组没有赋值
        if(typeof objoption.change=='function')
            objoption.change();
        if(typeof(fielddepend)!='undefined'&&fielddepend!=undefined)
        {
            var sourcename = objoption.name;
            var sourcevalue = objoption.value;
            fielddepend.fieldValueChange(sourcename, sourcevalue);
        }
        //选择字段带出关联信息 //edit:duan date:2024/12/9 reason: 增加判断是否需要执行关联带出 getHaveRelated
        if(this.getHaveRelated() == 'yes'){
            getJsScript('include/js/relatedfield.js',function(){
                getRelatedFieldData(that.popupobj.module,optionvalue,'',fldname,that.popupobj.module,'select');
            });
        }

        //ls 20240320 分录下拉框带出值 //edit:duan date:2024/12/9 reason: 增加判断是否需要执行关联带出 getHaveRelated
        if(that.detailrowindex>0 && this.getHaveRelated() == 'yes'){
            getJsScript('include/js/detail_selectReference.js',function(){
                var reference_arr=[];
                reference_arr.push('');
                reference_arr.push(that.popupobj.module);
                reference_arr.push(fldname);
                reference_arr.push(that.detailrowindex);
                //console.log(reference_arr);
                var fun_detail_selectReference = new detail_selectReference(reference_arr,'',that.popupobj);

                fun_detail_selectReference.getRelatedModuleField(that.popupobj.module,'',that.detailrowindex,fldname);
            });
        }


        //处理下拉框引起重新赋值的操作
        that.getSpecialRelatedData(that.detailrowindex,fldname,optionvalue);


        if(typeof cls_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined")
        {
            cls_wxOpenDataobj.bindAllOpenDataByPopupObj(that.popupobj);
        }


    }
    this.setSearchComboxHtml=function(obj)
    {
        if(this.width>0)
        {
            width=this.width-10;
        }
        else
        {
            width=198;
        }
        //width=parseInt(ld(obj).parent().css("width"))-26;

        var fldname=ld(obj).attr("name");

        that.selectobj=obj;
        var   currenLeft = parseInt(ld(obj).offset().left)-3;
        var   currenTop = ld(obj).offset().top-ld("#"+that.popupobj.divid).scrollTop();
        //zxm 20221117 分录冻结列导致下拉框看不到
        var drophtml = '<div cssposition="fixed" style="position:fixed;display:none;left:'+currenLeft+'px;width:'+width+'px; top: '+currenTop+'px;" class="chzn-drop" name="dv_drop_'+fldname+'" >'
        if(that.detailrowindex>0) {
            var objtd = Tools.getParentobjByChild(obj, 'td');//zxm 20221117 下拉框所在的td父级
            var tdposition = objtd.css('position');
            if(tdposition=='sticky'){
                drophtml = '<div cssposition="fixed" style="display:none;" class="chzn-drop" name="dv_drop_'+fldname+'" >'
            }
        }

        var colorstyle = '';
        if(!empty(that.picklistColors)){
            colorstyle = 'color: '+that.picklistColors[ld(obj).val()]+';';// 分录下拉框字段——获取选中选项的颜色
        }
        
        // CrmPopup.getPopupObj('last').picklist_end_foucs(event,'assigned_user_id')
        var comboxhtml='';
        comboxhtml+=' <div class="row-fluid"  name="dv_cmb_'+fldname+'" style="display:inline">';

        comboxhtml+='   <span class="span10">';

        comboxhtml+='    <div name="dv_chzn_'+fldname+'" class="chzn-container chzn-container-single"   style="width:'+(parseInt(width)-3)+'px"  onMouseLeave="cmb_mouseleave(event,\''+fldname+'\')">';
        comboxhtml+='       <a dvtop="'+currenTop+'" dvleft="'+currenLeft+'" class="chzn-single" dropdownname="'+fldname+'" tag="arrow" href="javascript:void(0)" tabindex="-1" name="cmb_a_'+fldname+'">';
        if(this.searchhtmltype=='text')
            comboxhtml+='           <input class="commonDetailedTextBox" type="text" tag="txt_search" autocomplete="off" style="width:'+(parseInt(width)-13)+'px;margin-left: -10px;margin-top: -1px;border-style:none; '+colorstyle+'" tabindex="0" value="" name="cmb_span_optiontext_'+fldname+'" id="cmb_span_optiontext_'+fldname+'">';
        else
            comboxhtml+=' <div picklisttype="smownerpicklist" onclick="CrmPopup.getPopupObj(\'last\').picklist_end_foucs(event,\''+fldname+'\')" contenteditable=true class="commonDetailedTextBox outline Bornone" tag="txt_search" style="width:'+(parseInt(width)-13)+'px;margin-left: -10px;border-style:none;" tabindex="0" value=""  name="cmb_span_optiontext_'+fldname+'" id="cmb_span_optiontext_'+fldname+'"></div>';

        comboxhtml+='           <div> <b></b></div>';
        comboxhtml+='       </a>';
        comboxhtml+=drophtml;
        comboxhtml+=' 		         <ul class="chzn-results" name="cmb_ul_'+fldname+'">';
        comboxhtml+='                  <li style="" class="" name="li_chzn_'+fldname+'" >'+arrJsPopLabel['NOMATCHINGITEMS']+'</li>';
        comboxhtml+=' 			 </ul>';
        comboxhtml+=' 		</div>'
        comboxhtml+='	 </div>';
        comboxhtml+='  </span>';
        comboxhtml+='</div>';
        var trobj=that.trobj;
        if(that.detailrowindex>0)
        {
            var tmpobj=ld(trobj).find(" [name='dv_cmb_"+fldname+"']");
        }
        else
            var tmpobj=ld("#"+that.popupobj.divid+" [name='dv_cmb_"+fldname+"']");
        if(tmpobj.length>0)
        {
            ld(tmpobj).remove();
        }
        //alert(comboxhtml);
        ld(obj).parent().append(comboxhtml);

        if(that.detailrowindex>0)
        {
            var tmpobj=ld(trobj).find(" [name='dv_cmb_"+fldname+"']");
        }
        else
            var tmpobj=ld("#"+that.popupobj.divid+" [name='dv_cmb_"+fldname+"']");
        ld(obj).css("display",'none');


        if(ld(obj).prop("tagName")=='SELECT')
            var text=ld(obj).find("option:selected").text();
        else
        {
            var value=ld(obj).val();
            var text='';
            ld.each(that.picklistcontent,function(tmptext,tmpvalue){
                if(value==tmpvalue)
                {
                    text=tmptext;
                    return false
                }
            })
        }

        if(this.searchhtmltype=='text')
            ld(tmpobj).find("input[name='cmb_span_optiontext_"+fldname+"']").val(text);
        else
            ld(tmpobj).find("div[name='cmb_span_optiontext_"+fldname+"']").html(text);


        ld(tmpobj).find("a[name='cmb_a_"+fldname+"']").css("width",width+"px");

        //zxm 20230519 BUG0066736	 kfbcrm-加班单-单据分录-下拉框类型的字段，修改颜色后没有生效
        var tmpcolor = '';
        var optionobj = ld(that.selectobj).children();
        var text=ld(that.trobj).find(" [name='cmb_span_optiontext_"+that.name+"']").val();
        ld.each(ld(optionobj),function(){
            if(ld.trim(ld(this).text())==text)
            {
                tmpcolor=ld(this).attr("pickcolor");
            }
        });
        //txy 20231012 可搜索下拉框新样式
        ld('.changesearch .commonDetailedTextBox b').parent().css('border-left', 'none').css('background-color', '#F5F8FC');
        ld('.changesearch .chzn-single b').parent().css('border-left', 'none').css('background-color', '#F5F8FC');
        ld(that.trobj).find(" [name='cmb_span_optiontext_"+that.name+"']").css('color',tmpcolor);
        return comboxhtml;


    }

    this.setOptionText = function (optiontext){
        return optiontext;
    }

    //ls 240129 XUQIU20240125-03 深圳市意林电锁订单增加录单预警功能（徐江平） (自定义下拉框仓库,切换时执行带出金蝶库存数量的操作)
    this.getSpecialRelatedData = function (detailrowindex,fldname,optionvalue){
        if (account_version == 'yilin' && that.popupobj.module == 'SalesOrder' && fldname == 'sf4882') {
            var productId = that.popupobj.detaildatavalue_arr[detailrowindex-1].productid;
            if (empty(productId)) {
                return;
            }

            var urlstring = 'index.php?module=Users&action=UsersAjax&file=getSpecialRelatedData';
            ldAjax(urlstring, {"sf4882": optionvalue, "productid": productId,"frommodule":that.popupobj.module}, function (data) {
                if (data.code == 1) {
                    // var tableobj=that.popupobj.getDetailTableObj();
                    // var rowobj = ld(tableobj).find("tr[rowindex=" + detailrowindex + "]");//赋值的行对象;
                    // ld(rowobj).find("[name=sf6929]").val('50');

                    if (empty(data.result) || empty(data.result.sf6929)) {
                        var sf6929 = 0;
                    }else {
                        var sf6929 = data.result.sf6929;
                    }

                    that.popupobj.detaildatavalue_arr[detailrowindex-1].sf6929 = sf6929;
                    if (that.popupobj.detaildatavalue_arr[detailrowindex-1].hasOwnProperty("sf6929_name"))
                        that.popupobj.detaildatavalue_arr[detailrowindex-1].sf6929_name = sf6929;

                    that.popupobj.fieldformulaobj.CountsubTotal();//小计
                }

                DelProgressObjs();
            })
        }
// @edit:dong @date:2024/10/15 @reason: 中山佳健 仓库变动带出库存
        if (account_version == 'zsjiajian' && that.popupobj.module == 'OutboundOrder' && fldname == 'sf6309') {

            var productId = that.popupobj.detaildatavalue_arr[detailrowindex-1].productid;
            if (empty(productId)) {
                return;
            }

            var urlstring = 'index.php?module=Users&action=UsersAjax&file=getSpecialRelatedData';
            ldAjax(urlstring, {"sf6309": optionvalue, "productid": productId,"frommodule":that.popupobj.module}, function (data) {
                if (data.code == 1) {
                    // var tableobj=that.popupobj.getDetailTableObj();
                    // var rowobj = ld(tableobj).find("tr[rowindex=" + detailrowindex + "]");//赋值的行对象;
                    // ld(rowobj).find("[name=sf6929]").val('50');

                    if (empty(data.result) || empty(data.result.sf8692)) {
                        var sf8692 = 0;
                    }else {
                        var sf8692 = data.result.sf8692;
                    }

                    that.popupobj.detaildatavalue_arr[detailrowindex-1].sf8692 = sf8692;
                    if (that.popupobj.detaildatavalue_arr[detailrowindex-1].hasOwnProperty("sf8692_name"))
                        that.popupobj.detaildatavalue_arr[detailrowindex-1].sf8692_name = sf8692;

                    that.popupobj.fieldformulaobj.CountsubTotal();//小计
                }

                DelProgressObjs();
            })
        }


    }

}

