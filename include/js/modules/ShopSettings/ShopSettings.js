// ls 2021-10-26 【ID1001109】增加“小程序商城设置”
//保存选择的产品
function addProductsToTopic()
{
    var idstring='';
    if(document.addToPB.selected_id != undefined){
        var y=0;//所选条数
        var x = document.addToPB.selected_id.length;//总条数
        //再次选择时
        var z=0;
        for(i = 1; i <= 20 ; i++) {
            //wym BUG0072053 获取已选择的记录条数(最好能获取到已选择的记录value,否则判断不了重复选择的条数)
            if(ld('#relation_Products_'+i).length>0) {
                z = z + 1;
            }
        }
        if(x == undefined){
            cnt= 2;
            idstring = document.addToPB.selected_id.value;
            y = 1;
        }else{
            for(i = 0; i < x ; i++) {
                //获取选中的产品id
                if(document.addToPB.selected_id[i].checked) {
                    idstring = idstring+document.addToPB.selected_id[i].value+";";
                    y = y + 1;
                }
            }
            cnt = 1;
        }
        var allselect_num=z+y;
    }

    if (y != 0) {
        document.addToPB.idlist.value=idstring;
    }else{
        var confirm_str = arrJsPopLabel['PLEASESELECTONEENTITY'];
        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
        return false;
    }

    if (allselect_num > 20) {
        RemindsMsg("","LdPopWidth400px","","yes","yes","您选择了"+allselect_num+"条记录，批量选择产品只对前20条记录生效，是否继续？");
        ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
            var idarray = idstring.split(';');
            idarray = idarray.slice(0,20);//idarray.splice(0,20)
            idstring = idarray.join(';');
            startAddProductsToTopic(idstring);
            return false;
        });
    }else if(y > 0){
        startAddProductsToTopic(idstring);
    }
}

function startAddProductsToTopic(idstring) {
    var popupobj=CrmPopup.getPopupObj('last');
    var urlstring="index.php?module=ShopSettings&action=ShopSettingsAjax&file=HomepageSettings&type=topicproductset&mode=add";

    // var lastprevpopupobj=CrmPopup.getPopupObj('lastprev');
    var topicid = ld('select[name=pick_topic]').val();
    urlstring+='&idlist='+idstring+"&topicid="+topicid;

    ldAjax(urlstring,{},function(data){
        popupobj.CancelEvent();

        // RemindsMsg("","LdPopWidth400px","","yes","yes","保存成功");
        MessagePopup.TipOne_success('保存成功');

        //确定按钮
        ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
            refreshTopicProductList();//刷新专题产品列表
        });

    })

}



function ShopSettings()
{
    var that=this;

    //选择专题更新产品列表页面
    this.getTopicProductLists = function (obj) {
        var topicid = ld('select[name=pick_topic]').val();
        var url = 'index.php?module=ShopSettings&action=ShopSettingsAjax&file=HomepageSettings&ajax=yes&topicid='+topicid;
        ldAjax(url,"",function(data){
            if(data.code == 1){
                ld("[name=multitopiclist]").html(data.result.content);
                DelProgressObjs();
            }
        })
    }

    //首页专题设置 - 设置专题
    this.topicSet = function () {
        var popupobj = CrmPopup.getPopupObj("last");
        var crmPopupobj = CrmPopup.load("","","","LdPopWidth600px",'Settings',"","","","");
        crmPopupobj.prevshow();

        var url = 'index.php?module=ShopSettings&action=ShopSettingsAjax&file=HomepageSettings&type=topicset&mode=gettopic';
        ldAjax(url, '', function (data) {
            if (data.code == 1) {
                crmPopupobj.setParams(data.result.title,that.saveTopicSet,"","'LdPopWidth600px'",popupobj.module,"",data.result.oktext,"",data.result.canceltext,"");
                crmPopupobj.show(data.result.content);
                // 需要去掉的给高度
                crmPopupobj.reduceBodyHeight = 37;
                // 设置内容最大高度
                crmPopupobj.setPopBodyMaxHeight(".divPopOverflow");
                that.topicSort();
                that.movetable();
                tooltip(".sort-tip-items", {transition: true, time: 200});
            }

        })
    }

    //启用(默认)、停用专题
    this.presenceTopic = function (obj) {
        if(ld(obj).prop("checked")) {//该类会显示成红色（停用）
            ld(obj).attr('presence','yes');
        } else {
            ld(obj).attr('presence','no');
        }
    };

    //@edit:ljj,2023-07-17,reason:BUG0068716:  增加按钮、拖动和tooltip
    this.movetable = function(){
        var dragobj = ld("table[name=topic_table]").find("tbody");
        ld.each(dragobj,function(index,obj){
            Sortable.create(obj, {
                group: 'topicSetMove',
                draggable:".ld-topic-draggable",
                handle:".drag-handle",
                onEnd: function (evt){
                        }
            })
        });
    };

    //上移
    // this.moveUp = function(obj){
    //     var selfobj = ld(obj).parent().parent(); //当前tr对象
    //     var selfval = selfobj.find('input').val();//当前tr对象里input值（将tr整体移动后，上移下移input框变成空值，修改过专题名称input里的值过不去，只能重新赋值）
    //     var prevobj = ld(obj).parent().parent().prev();//前一个tr对象
    //     prevobj.before(selfobj.prop('outerHTML'));
    //     selfobj.remove();
    //
    //     prevobj.prev().find('input').val(selfval);//重新赋值
    //     that.topicSort();//重新排序
    // }
    //
    // //下移
    // this.moveDown = function(obj){
    //     var selfobj = ld(obj).parent().parent(); //当前tr对象
    //     var selfval = selfobj.find('input').val();
    //     var nextobj = ld(obj).parent().parent().next();//后一个tr对象
    //     nextobj.after(selfobj.prop('outerHTML'));//html() -- 所有子元素，不包括自身
    //     selfobj.remove();
    //
    //     nextobj.next().find('input').val(selfval);
    //     that.topicSort();//重新排序
    // }

    //删除  点击保存按钮再去真正执行删除操作  TODO...
    this.deleteTopic = function(obj){
        var selfobj = ld(obj).parent().parent(); //当前tr对象
        var topicid = selfobj.attr('topicid');
        if (!empty(topicid)){//删除已有的专题
            // var delete_str = arrJsPopLabel['DELETEDTOPICEDIT'];
            RemindsMsg("","LdPopWidth400px","","yes","yes","确定要删除该专题及专题下的产品吗（该操作不会删除产品模块产品）？");
            //确定按钮
            ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
                var url = 'index.php?module=ShopSettings&action=ShopSettingsAjax&file=HomepageSettings&type=topicset&mode=deletetopic&topicid='+topicid;
                ldAjax(url,"",function(data){
                    if(data.code == 1){
                        selfobj.remove();
                        that.topicSort();
                        MessagePopup.TipOne_success ("删除成功");
                        DelProgressObjs();
                    }else{
                        RemindsMsg("","LdPopWidth400px","","yes","yes","删除失败");
                        DelProgressObjs();
                        return false;
                    }
                })
            });
        }else{//删除刚刚新增的专题
            ld(obj).parent().parent().remove();
            that.topicSort();
        }

    }

    //重新序列化专题排序
    this.topicSort = function(){
        var popupobj = CrmPopup.getPopupObj("last");
        var trobjs = ld("#"+popupobj.divid+" [name=topic_table]").find("tr").not(":first");//不要第一个

        //只剩一个专题的时候不能删除，隐藏所有操作图标
        if (trobjs.length == 1 ) {
            ld("#"+popupobj.divid+" [name=topic_table]").find("tr:last").find(".sort_td").hide();
            return;
        }

        // ld('#'+popupobj.divid+' .sort_td:first').children("a:first").hide();
        // ld('#'+popupobj.divid+' .sort_td:last').children("a:eq(1)").hide();

        var _sort = 1;
        ld.each(trobjs,function(tmpindex,tmptrobj){
            if(_sort == 1){//第一个
                ld(tmptrobj).find('[name=moveUp]').hide();
                ld(tmptrobj).find('[name=moveDown]').show();
            }else{
                if(_sort == trobjs.length){//最后一个
                    ld(tmptrobj).find('[name=moveUp]').show();
                    ld(tmptrobj).find('[name=moveDown]').hide();
                }else{//中间的
                    ld(tmptrobj).find('[name=moveUp]').show();
                    ld(tmptrobj).find('[name=moveDown]').show();
                }
            }
            _sort++;
        });

    }

    //新增专题
    this.addTopicSet = function(){
        var popupobj=CrmPopup.getPopupObj("last");
        var lasttr = ld('#'+popupobj.divid+' table:first tr:last');

        var addtr = '<tr class="ld-topic-draggable" topicid="">' +
            '<td>' +
            '<input class="ld-input-inner" name="topicid_" oldvalue="" value="" type="text">' +
            '</td>'+
            '<td>'+
            /* wym BUG0072059 kfbcrm-商城设置-点击“首页专题设置”，选择专题右边设置页面，新增一个专题，点击保存显示保存成功，但是下拉框不显示新增的专题*/
            '<input class="second_switch" type="checkbox" name="presenceTopic" presence="yes" onclick="ShopSettingsobj.presenceTopic(this);" checked> </input>'+
            '</td>'+
            '<td class="sort_td drag-handle">'+
            '<i class="ld-fonticon ld-fonticon-del" name="deleteTopic" style="cursor: pointer;" onclick="ShopSettingsobj.deleteTopic(this);" title="删除"></i>'+
            '<a class="Anu3_a ld-dragicon sort-tip-items" data-tip="'+arrJsPopLabel['DRAGTOSORT']+'"  data-direction="left" data-type="position"  style="cursor: move" ></a>'+
            '</td>'+
            '</tr>';
        ld(lasttr).after(addtr);


        that.topicSort();

        CrmPopup.findHtmlobj(popupobj.divid,'new').focus();
        //31715: PC端：编辑下拉框选项，当选项比较多时新增选项的时候应该自动把滚动条滚动最下面
        ld("#dv_scroll").scrollTop(document.getElementById('dv_scroll').scrollHeight+10);
    }

    //保存专题
    this.saveTopicSet = function () {
        var url = 'index.php?module=ShopSettings&action=ShopSettingsAjax&file=HomepageSettings&type=topicset&mode=savetopic';

        var popupobj = CrmPopup.getPopupObj("last");
        var trobjs = ld("#"+popupobj.divid+" [name=topic_table]").find("tr").not(":first");//不要第一个
        var topic_obj = '';
        var topic_array = new Array();
        var is_empty = false;
        ld.each(trobjs,function(tmpindex,tmptrobj){
            // console.log(tmpindex);
            // console.log(tmptrobj);
            var topicid = ld(tmptrobj).attr("topicid");
            var topic_name = ld(tmptrobj).find('input[name=topicid_'+topicid+']').val().trim();//ld(tmptrobj).children("td:first").find('input').val()
            if (empty(topic_name)) {
                is_empty = true;
                return false;//退出循环
            }
            // var old_topic_name = ld(tmptrobj).find('input[name=topicid_'+topicid+']').attr("oldvalue");
            // if (topic_name == old_topic_name) {//原本想着当专题名称有被改变或者新增时才去保存，考虑到有排序，只能全部传后台
            //     return true; //continue   return false=break
            // }
            var presence = ld(tmptrobj).find('input[name=presenceTopic]').attr("presence");
            topic_obj = new Object();
            topic_obj.topicid = topicid;
            topic_obj.topic_name = topic_name;
            // topic_obj.old_topic_name = old_topic_name;
            topic_obj.presence = presence;
            topic_array.push(topic_obj);
        });

        if (is_empty) {
            RemindsMsg("","LdPopWidth400px","","yes","yes","专题名称不能为空");
            return false;
        }


        url += "&topiclists="+encodeURIComponent(JSON.stringify(topic_array));
        ldAjax(url, "", function (data) {
            popupobj.CancelEvent();
            if (data.code == 1) {
                //wym BUG0072057 kfbcrm-商城设置-点击“首页专题设置”，选择专题右边设置页面，关闭“精选商品”专题，点击保存，“保存成功”显示图标错误
                MessagePopup.TipOne_success('保存成功');
                //确定按钮
                ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
                    that.refreshTopicProductHtml();

                });
                DelProgressObjs();

            } else {
                RemindsMsg("","LdPopWidth400px","","yes","yes","保存失败");
                DelProgressObjs();
                return false;
            }
        })

    }

    //刷新专题产品整个页面
    this.refreshTopicProductHtml = function () {
        var url = 'index.php?module=ShopSettings&action=ShopSettingsAjax&file=HomepageSettings';
        ldAjax(url, '', function (data) {
            if (data.code == 1){
                ld(" [name=SettingRightContent]").html(data.result.content);

                var selectobj=ld(" [name=SettingRightContent] .main_grid_top").find("[fieldtype=select]");
                if(selectobj.length>0&&selectobj!=undefined){
                    var cls_resetComboxHtmlobj=new cls_resetComboxHtml(selectobj.attr("name"));
                    CrmPopup.global_listPopupObj=[];
                    var obj=new Object();
                    obj.divid="SettingRightContent";
                    CrmPopup.global_listPopupObj.push(obj);
                    obj.CancelEvent=function(){
                        return false;
                    }
                    cls_resetComboxHtmlobj.setPopupObj(obj);
                    cls_resetComboxHtmlobj.setSearchComboxWidthByhtml(selectobj,150);
                    ld(' .grid-view-title').css('width', ld(' .grid-view-title').width()+20+'px');
                    ld(' .chzn-container').css('margin-top', '17px');
                    ld(' .chzn-drop').css('margin-left', '10px');
                }
                initRightContentHeight();//加载右侧内容中菜单和详细内容高度
            }
            DelProgressObjs();
        })
    }

    //专题选择产品 CrmPopupWindow

    //专题取消产品 id: topicid和productid的主键id
    this.deleteTopicProductRel = function (id) {
        var idstring = '';
        if (empty(id)) {//批量取消产品
            if(ld('input[name=selected_id]:checked').length == 0){//请至少选择一条记录
                var confirm_str = arrJsPopLabel['PLEASESELECTONEENTITY'];
                RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                return false;
            }

            ld('input[name=selected_id]:checked').each(function(){
                idstring += ld(this).val()+';';
            });
        }else{//列表操作列取消单个产品
            idstring = id;
        }


        // return false;
        var confirm_str = arrJsPopLabel['AREYOUSUREYOUWANTTOCANCELTHECONNECTION'];
        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
        //确定按钮
        ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
            var topicid = ld('select[name=pick_topic]').val();
            var url = 'index.php?module=ShopSettings&action=ShopSettingsAjax&file=HomepageSettings&type=topicproductset&mode=delete&topicid='+topicid+'&idlist='+idstring;
            ldAjax(url, '', function (data) {
                if (data.code == 1){
                    refreshTopicProductList();//刷新专题产品列表
                }
                // RemindsMsg("","LdPopWidth400px","","yes","yes","取消关联成功");
                MessagePopup.TipOne_success('取消关联成功');
                DelProgressObjs();
            })
        });
    }


    //设置行拖动
    //行字段拖动调换顺序
    //分组字段 与非分组字段不能相互调换
    this.setSortable = function(){
        var sortObj = ld('#topicproductlisttable').find("tbody");
        Sortable.create(ld(sortObj).get(0), {
            handle: '.can-sortable',
            draggable: "[tag=data]", 
            /*onMove: function (evt, originalEvent) {
                return true;
            },*/
            onEnd: function (evt) {
                // https://www.jianshu.com/p/c282934da66c  http://www.sortablejs.com/options.html
                if(evt.newIndex != evt.oldIndex){
                    //evt.from 上一个列表;evt.to 目标列表;evt.item 拖动的 HTMLElement
                    that.setTopicProductSequence();
                }

            }
        });
    }

    //拖动后给专题下的产品重新排序
    this.setTopicProductSequence = function () {
        var idstring = '';
        ld('input[name=selected_id]').each(function(){
            idstring += ld(this).val()+';';
        });

        var url = 'index.php?module=ShopSettings&action=ShopSettingsAjax&file=HomepageSettings&type=topicproductset&mode=sequence&idlist='+idstring;
        ldAjax(url, '', function (data) {
            DelProgressObjs();
        })
    }

}
var ShopSettingsobj = new ShopSettings();

//刷新专题产品列表
function refreshTopicProductList() {
    var topicid = ld('select[name=pick_topic]').val();
    var url = 'index.php?module=ShopSettings&action=ShopSettingsAjax&file=HomepageSettings&ajax=yes&topicid='+topicid;
    ldAjax(url, '', function (data) {
        if (data.code == 1){
            ld("div[name=multitopiclist]").html(data.result.content);
        }
        DelProgressObjs();
    })
}

//参考PriceBooks.js  关联的产品列表页面
function fun_ProductTopic()
{
    var that=this;
    this.startpage=1;
    this.searchtype="";
    that.pageclick='no';//是否点击的分页
    this.basicsearch_field="";
    this.basicsearch_content="";
    this.init=function()
    {
        this.startpage=1;
        this.searchtype="";
        that.pageclick='no';//是否点击的分页
        this.basicsearch_field="";
        this.basicsearch_content="";
    }
    this.highsearch=function()
    {
        that.searchtype='Advanced';
        that.pageclick='no';
        that.search();
    }
    this.basicsearch_keyup=function(event){
        if(event.keyCode == 13){
            that.basicsearch();
        }
    }
    this.basicsearch=function(){
            that.pageclick='no';
            that.searchtype='Basic';
            that.search();
    }
    this.search=function()
    {
        var popupobj=CrmPopup.getPopupObj("last");
        var lastprevpopup=CrmPopup.getPopupObj('lastprev');

        var urlstring = 'module=Products&action=ProductsAjax&ajax=yes&search=true&start='+that.startpage;
        urlstring+="&file=AddProductsToTopic";
        if(that.searchtype == 'Basic')
        {
            that.basicsearch_field=ld("#"+popupobj.divid+" [name=search_field]").val();//查询的字段类型
            that.basicsearch_content=ld("#"+popupobj.divid+" [name=search_text]").val();//所输入的内容
            urlstring += '&search_field='+that.basicsearch_field+'&searchtype=BasicSearch&search_text='+encodeURIComponent(that.basicsearch_content);
            urlstring+="&query=true"
            lastprevpopup.advft_criteria="";
            lastprevpopup.advft_criteria_groups="";

            ld("#"+lastprevpopup.divid+" [name=search_text]").val(that.basicsearch_content);
        }
        else if(that.searchtype=='Advanced')
        {
            that.basicsearch_field="";
            that.basicsearch_content="";
            if (empty(popupobj.advft_criteria)) {//不明所以然，popupobj 的 advft_criteria有值却打印不出来，必须经过New_checkAdvancedFilter处理一下才行，当下一页时就不能在处理了，否则又取不到值。。。
                if(!New_checkAdvancedFilter()) return false;
            }

            var advft_criteria =popupobj.advft_criteria;
            var advft_criteria_groups = popupobj.advft_criteria_groups;

            lastprevpopup.advft_criteria=advft_criteria;
            lastprevpopup.advft_criteria_groups=advft_criteria_groups;

            urlstring += '&advft_criteria='+encodeURIComponent(advft_criteria)+'&advft_criteria_groups='+advft_criteria_groups;
            urlstring += '&searchtype=advance';
            urlstring+="&query=true";
            // 保存高级查找历史
            var search_history_url = '&advft_criteria='+advft_criteria+'&advft_criteria_groups='+advft_criteria_groups+'&searchfrom=selectsearchdetail&searchtype=advance';
            getJsScript('include/js/search.js', function () {
                save_search_history(search_history_url,'Products');
            });
        }


        ld.ajax({
            type:'post',
            dataType:"json",
            timeout:30000,
            url:"index.php?"+urlstring,
            success:function(data){

                if(that.pageclick!='yes'&&that.searchtype=='Advanced')
                    CrmPopup.getPopupObj('last').CancelEvent();

                that.pageclick='no';

                var prevpopupobj=CrmPopup.getPopupObj('last');

                CrmPopup.findHtmlobj(prevpopupobj.divid,'ListViewContents').html(data.result.content);

                CrmPopup.findHtmlobj(prevpopupobj.divid,'navigationoutput').html(data.result.navigationoutput);
                prevpopupobj.center();
                that.setCheckBoxEvent();
                that.setCheckBoxPropselected(popupobj);

            }
        })
    }
    this.search.tagname='fun_ProductTopic.getInstance().search';
    this.setCheckBoxEvent = function(){
        var popupobj=CrmPopup.getPopupObj("last");
        ld("#"+popupobj.divid+" [name=selected_id]").bind("click",function(){
            fun_setCrmPopupWindow.setChooseInfo_arr(ld(this))
        })
        ld("#"+popupobj.divid+" [name=selected_all]").bind("click",function(){
            ld.each(ld("#"+popupobj.divid+' [name=selected_id]'),function(){
                fun_setCrmPopupWindow.setChooseInfo_arr(ld(this))
            })
        })
        ld("#"+popupobj.divid+" [name=select_all]").bind("click",function(){
            ld.each(ld("#"+popupobj.divid+' [name=selected_id]'),function(){
                fun_setCrmPopupWindow.setChooseInfo_arr(ld(this))
            })
        })
    }
    this.setCheckBoxPropselected=function(popupobj){
        ld.each(popupobj.chooseproductid_arr,function(tmpindex,tmpproductid){
            ld("#"+popupobj.divid+" tr[id="+tmpproductid+"]").find("input[value="+tmpproductid+"]").prop("checked",true); 
        })
    }
    this.basicsearchpop=function() //BUG0068709 xxy 2023-7-26 商城设置->首页专题设置，选择产品界面“基本查找”显示样式不对 所以去掉了单独弹窗
    {
        var lastpopupobj=CrmPopup.getPopupObj("last");//选择产品的弹出层
        $("status").style.display="none";
        this.startpage=1;//搜索时，开始页必须重新计算，不然结果集页数如果小于该值会出错
        getJsScript("include/js/SystemPopup/ListBasicSearchPopup.js",function(){

            ld.each(lastpopupobj.basicsearchheaders,function(tmpindex,tmpinfo){
                var optionhtml="<option value='"+tmpinfo.columnname+"'>"+tmpinfo.fieldlabel+"</option>";
                ld("#"+lastpopupobj.divid+" [name=search_field]").append(optionhtml);
            })
        });
    }
    this.clearPopupLayerSearch=function(obj){
        var popupobj=CrmPopup.getPopupObj("last");
        var divid=popupobj.divid;
        ld('#'+divid+' #basicSearchNewDiv').find('[name=search_text]').val('');
        that.basicsearch();
    }
    this.advancesearchpop=function()
    {
        //showPopupHighSearch
        //高级查询的弹出层
        global_showPopupHighSearch(fun_ProductTopic.getInstance().highsearch);
        var Popupobj=CrmPopup.getPopupObj('last');

    }
    this.getProductsTopicList_js=function(start)
    {
        //分页
        this.startpage=start;
        this.pageclick='yes';
        var popupobj=CrmPopup.getPopupObj('last');
        ld("#"+popupobj.divid+' [name=pagenum]').val(start);
        that.search();
    }

    /*this.searchrelateproducts=function(event)
    {
        console.log(event);
        if(event.keyCode==13)
        {
            var popupobj=CrmPopup.getPopupObj('last');
            var searchvalue=ld("#"+popupobj.divid+' [name=searchvalue]').val();
            var fieldlabel=ld("#"+popupobj.divid+' [name=searchvalue]').attr("fieldlabel");

            popupobj.advft_criteria='[null,{"groupid":"1","columnname":"ld_products:product_no:product_no:Products_'+fieldlabel+':V","comparator":"c","value":"'+searchvalue+'","columncondition":""}]';
            popupobj.advft_criteria_groups='[null,{"groupcondition":""}]';

            DetailViewRelation.searchByPopupobj(popupobj)
        }
    }*/
}

fun_ProductTopic.getInstance=function()
{
    var popupobj=CrmPopup.getPopupObj('last');
    if(popupobj.producttopicsobj==undefined)
    {
        popupobj.producttopicsobj=new fun_ProductTopic();
    }
    return popupobj.producttopicsobj;
}
//商城设置 - 小程序商城设置 - 小程序接口设置
function InterfaceSettings_edit(){
	var surl = 'index.php?module=ShopSettings&action=ShopSettingsAjax&file=InterfaceSettings_edit';
	var popupobj=CrmPopup.getPopupObj("last");
	var crmPopupobj=CrmPopup.load("","","","LdPopWidth600px",'Settings',"","","","");
	crmPopupobj.prevshow();
	ldAjaxNoProgress(surl,"",function(data){
		if(data.code==1){
			crmPopupobj.setParams(data.result.title,InterfaceSettingsSave,"","LdPopWidth600px",'Settings',"",data.result.oktext,"",data.result.canceltext);
			crmPopupobj.show(data.result.content);
            // 设置内容最大高度
            crmPopupobj.setPopBodyMaxHeight(".divPopOverflow");
		}
	})
}
//系统设置 - 接口设置 - 小程序接口设置 - 保存
function InterfaceSettingsSave() {
	var surl = 'index.php?module=ShopSettings&action=ShopSettingsAjax&file=InterfaceSettings_edit&ajax=save';
	var popupobj=CrmPopup.getPopupObj("last");
	var appid = ld("#"+popupobj.divid+" [name=appid]").val();
	var appsecret = ld("#"+popupobj.divid+" [name=appsecret]").val();
    var appname = ld("#"+popupobj.divid+" [name=appname]").val();
    var custelno = ld("#"+popupobj.divid+" [name=custelno]").val();
    var sharedescription = ld("#"+popupobj.divid+" [name=sharedescription]").val();
    var displayinvoice = ld("#"+popupobj.divid+" [name=displayinvoice]").prop('checked');
    if(empty(appid)||appid == undefined){
        var confirm_str = 'appId'+arrJsPopLabel['CANOTEMPTY'];
        RemindsMsg("","LdPopWidth400px",'',"yes","yes",confirm_str);
        return; 
    }
    if(empty(appsecret)||appsecret == undefined){
        var confirm_str = 'appSecret'+arrJsPopLabel['CANOTEMPTY'];
        RemindsMsg("","LdPopWidth400px",'',"yes","yes",confirm_str);
        return; 
    }
    if(empty(appname)||appname == undefined){
        var confirm_str = '小程序名称'+arrJsPopLabel['CANOTEMPTY'];
        RemindsMsg("","LdPopWidth400px",'',"yes","yes",confirm_str);
        return; 
    }
    // if(empty(custelno)||custelno == undefined){
    //     var confirm_str = '客服电话'+arrJsPopLabel['CANOTEMPTY'];
    //     RemindsMsg("","LdPopWidth400px",'',"yes","yes",confirm_str);
    //     return; 
    // }
    //zkt 0049583: 小程序商城设置-小程序接口设置-小程序接口参数-保存时判断appId为18位，不为18位给出提示“请确定appId是否正确，appId应为18位，当前不符合”
    if(appid.length!=18){
        var confirm_str = '请确定appId是否正确，appId应为18位，当前不符合';
        RemindsMsg("","LdPopWidth400px",'',"yes","yes",confirm_str);
        return;
    }
    //zkt 0049584: 小程序商城设置-小程序接口设置-小程序接口参数-保存时判断appSecret为32位，不为32位给出提示“请确定appSecret是否正确，appSecret应为32位，当前不符合”
    if(appsecret.length!=32){
        var confirm_str = '请确定appSecret是否正确，appSecret应为32位，当前不符合';
        RemindsMsg("","LdPopWidth400px",'',"yes","yes",confirm_str);
        return;
    }
    
    //判断客服电话格式是否正确,暂时弃用
    // var regTel = /^(400)(-(\d{3,4}))(-(\d{3,4}))$/.test(custelno);//400开头的电话
    // var regTel1 = /^(([0\+]\d{2,3}-)?(0\d{2,3})-)(\d{7,8})(-(\d{3,}))?$/.test(custelno);//带区号的固定电话
    // var regTel2 = /^(\d{7,8})(-(\d{3,}))?$/.test(custelno);//不带区号的固定电话 
    // var regTel3 = /^(\d{8,11})?$/.test(custelno);//不带-号的手机号
    // if(!regTel&&!regTel1&&!regTel2&&!regTel3)
    // {
    //     var confirm_str = '请输入正确的客服电话格式！';
    //     RemindsMsg("","LdPopWidth400px",'',"yes","yes",confirm_str);
    //     return;
    // }
	surl += '&appid='+encodeURIComponent(appid)+'&appsecret='+encodeURIComponent(appsecret)+'&appname='+encodeURIComponent(appname);
    surl += '&custelno='+encodeURIComponent(custelno);
    surl += '&displayinvoice='+encodeURIComponent(displayinvoice);
    //分享描述
    surl +="&sharedescription="+encodeURIComponent(sharedescription);
    //分享图片判断
    var divid = popupobj.divid;
    var imgfileobj = ld("#"+divid).find(' input[id=sharepicture]');
    var formData = new FormData();
    var havesharepicture= 'yes';
    //zkt 0049810: 中榜集团>220.168.85.107:85/crm>商城设置>小程序设置界面：上传“分享图片”后，再次编辑保存，分享图片就不会显示了。
    if(ld("#"+divid).find(' span[name=span_sharepicture]').get(0).innerHTML==''){
        havesharepicture='no';
    }
    if(imgfileobj[0].value != ''){
        havesharepicture='yes';
        formData.append("sharepicture",imgfileobj[0].files[0]);
    }
    formData.append('havesharepicture',havesharepicture);
    ld.ajax({
			type: 'POST',
			dataType: 'json',
			processData: false, // 告诉jquery不要处理数据
			contentType: false, // 告诉jquery不要设置contentType
			data: formData,
			url: surl,
			success: function(data) {
	
        		if(data.code==1){
        			popupobj.CancelEvent();
        			//刷新列表
        			var surl = "index.php?module=ShopSettings&action=InterfaceSettings&ReportHeader=dheader";
        			ldAjaxNoProgress(surl,"",function(data){
        				if(data.code==1){
        					ld(' [name=SettingRightContent]').html(data.result.content);
        				}
        			})
                    DelProgressObjs();
        		}else{
        			RemindsMsg("","LdPopWidth400px","","yes","yes",data.msg);
                    DelProgressObjs();
        			return fasle;
        		}
          }
	})
}
//系统设置 - 接口设置 - 小程序设置 - 更新（目前仅针对 是否显示发票 的更新）
function InterfaceSettingsUpdate(obj) {
    var surl = 'index.php?module=ShopSettings&action=ShopSettingsAjax&file=InterfaceSettings_edit&ajax=update';
    var displayinvoice = ld(obj).prop('checked');
    surl += '&displayinvoice='+encodeURIComponent(displayinvoice);
    ldAjaxNoProgress(surl,"",function(data){
        if(data.code==1){
            //刷新列表
            var surl = "index.php?module=ShopSettings&action=InterfaceSettings&ReportHeader=dheader";
            ldAjaxNoProgress(surl,"",function(data){
                if(data.code==1){
                    ld(' [name=SettingRightContent]').html(data.result.content);
                }else{
                    RemindsMsg("","LdPopWidth400px","","yes","yes",data.msg);
                    DelProgressObjs();
                    return false;
                }
            })
            DelProgressObjs();
        }
    })
}
//删除图片span内容
function ShopSettingsdeletepicture(fieldname){
    var popupobj=CrmPopup.getPopupObj('last');
    ld("#"+popupobj.divid+" [name=div_upload_span]").css('display','none');
	if (popupobj != undefined){
		ld("#"+popupobj.divid+" [name=span_"+fieldname+"]").text('');
	}else{
		ld(" [name=span_"+fieldname+"]").text('');
	}
    var imgfileobj = ld("#"+popupobj.divid).find(' input[id='+fieldname+']');
    if(imgfileobj[0].value != ''){
        imgfileobj[0].value = '';
    }
	return true;
}
//上传图片文件检查文件名
function ShopSettingsSelectpicture(form_ele) {
	if (form_ele.value == '') return true;
    
	var value = getFileNameOnlys(form_ele.value);
    
	// Color highlighting logic
	var err_bg_color = "#FFAA22";

	if (typeof(form_ele.bgcolor) == "undefined") {
		form_ele.bgcolor = form_ele.style.backgroundColor;
	}
	// Validation starts here
	var valid = true;
    
	if (value!=undefined&&value.length > 255) {
		var confirm_str = arrJsPopLabel['FILENAMESCANOTEXCEED255CHAR'];
		RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
		valid = false;
	}
	if(!/\.(gif|jpg|jpeg|png|bmp|ico|GIF|JPG|JPEG|PNG|BMP|ICO)$/.test(value))
	{
		var confirm_str = value+arrJsPopLabel['CANNOTUOLOAD']+','+arrJsPopLabel['THEALLOWEDTYPES']+'jpg、jpeg、gif、png、bmp、ico;';
		RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
		form_ele.value = '';
		return false;
	}
	if (!valid) {
		form_ele.style.backgroundColor = err_bg_color;
		return false;
	}
	form_ele.style.backgroundColor = form_ele.bgcolor;

	var popupobj=CrmPopup.getPopupObj('last');
    ld("#"+popupobj.divid+" [name=div_upload_span]").css('display','block');
	if (popupobj != undefined){
		ld("#"+popupobj.divid+" [name=span_"+form_ele.name+"]").text(value);
        ld("#"+popupobj.divid+" [name=span_"+form_ele.name+"]").attr('title',value);
	}else{
		ld(" [name=span_"+form_ele.name+"]").text(value);
        ld(" [name=span_"+form_ele.name+"]").attr('title',value);
	}
	return true;
}

//商城设置 - 小程序商城设置 - 商户号设置
function MerchantNoSettings_edit(){
	var surl = 'index.php?module=ShopSettings&action=ShopSettingsAjax&file=MerchantNoSettings_edit';
	var popupobj=CrmPopup.getPopupObj("last");
	var crmPopupobj=CrmPopup.load("","","","LdPopWidth600px",'Settings',"","","","");
	crmPopupobj.prevshow();
	ldAjaxNoProgress(surl,"",function(data){
		if(data.code==1){
			crmPopupobj.setParams(data.result.title,MerchantNoSettingsSave,"","LdPopWidth600px",'Settings',"",data.result.oktext,"",data.result.canceltext);
			crmPopupobj.show(data.result.content);
            // 设置内容最大高度
            crmPopupobj.setPopBodyMaxHeight(".divPopOverflow");
		}
	})
}
//系统设置 - 接口设置 - 商户号设置 - 保存
function MerchantNoSettingsSave() {
	var surl = 'index.php?module=ShopSettings&action=ShopSettingsAjax&file=MerchantNoSettings_edit&ajax=save';
	var popupobj=CrmPopup.getPopupObj("last");
	var merchantnum = ld("#"+popupobj.divid+" [name=merchantnum]").val();
	var merchantcertificatenum = ld("#"+popupobj.divid+" [name=merchantcertificatenum]").val();
	var apikey = ld("#"+popupobj.divid+" [name=apikey]").val();
	var apiv3key = ld("#"+popupobj.divid+" [name=apiv3key]").val();
    if(empty(merchantnum)||merchantnum == undefined){
        var confirm_label = ld("#"+popupobj.divid+" [name=merchantnum]").attr('tag');
        var confirm_str = confirm_label+arrJsPopLabel['CANOTEMPTY'];
        RemindsMsg("","LdPopWidth400px",'',"yes","yes",confirm_str);
        return; 
    }
    if(empty(merchantcertificatenum)||merchantcertificatenum == undefined){
        var confirm_label = ld("#"+popupobj.divid+" [name=merchantcertificatenum]").attr('tag');
        var confirm_str = confirm_label+arrJsPopLabel['CANOTEMPTY'];
        RemindsMsg("","LdPopWidth400px",'',"yes","yes",confirm_str);
        return; 
    }
    if(empty(apikey)||apikey == undefined){
        var confirm_label = ld("#"+popupobj.divid+" [name=apikey]").attr('tag');
        var confirm_str = confirm_label+arrJsPopLabel['CANOTEMPTY'];
        RemindsMsg("","LdPopWidth400px",'',"yes","yes",confirm_str);
        return; 
    }
    if(empty(apiv3key)||apiv3key == undefined){
        var confirm_label = ld("#"+popupobj.divid+" [name=apiv3key]").attr('tag');
        var confirm_str = confirm_label+arrJsPopLabel['CANOTEMPTY'];
        RemindsMsg("","LdPopWidth400px",'',"yes","yes",confirm_str);
        return; 
    }
    //zkt 0049586: 小程序商城设置-商户号设置-保存时判断【api密钥】和【apiv3密钥】为32位，不为32位给出提示
    if(apikey.length!=32){
        var confirm_str = '请确定api密钥是否正确，api密钥应为32位，当前不符合';
        RemindsMsg("","LdPopWidth400px",'',"yes","yes",confirm_str);
        return;
    }
    if(apiv3key.length!=32){
        var confirm_str = '请确定apiv3密钥是否正确，apiv3密钥应为32位，当前不符合';
        RemindsMsg("","LdPopWidth400px",'',"yes","yes",confirm_str);
        return;
    }
	surl += '&merchantnum='+encodeURIComponent(merchantnum)+'&merchantcertificatenum='+encodeURIComponent(merchantcertificatenum)
        +'&apikey='+encodeURIComponent(apikey)+"&apiv3key="+encodeURIComponent(apiv3key);
    ldAjax(surl,"",function(data){
		if(data.code==1){
			popupobj.CancelEvent();
			//刷新列表
			var surl = "index.php?module=ShopSettings&action=MerchantNoSettings&ReportHeader=dheader";
			ldAjaxNoProgress(surl,"",function(data){
				if(data.code==1){
					ld(' [name=SettingRightContent]').html(data.result.content);
				}
			})
            DelProgressObjs();
		}else{
			RemindsMsg("","LdPopWidth400px","","yes","yes",data.msg);
            DelProgressObjs();
			return fasle;
		}
	})
}



//商城设置 - 小程序商城设置 - 轮播图设置
function CarouselSettings_edit(obj,type,recordid){
    
	var surl = 'index.php?module=ShopSettings&action=ShopSettingsAjax&file=CarouselSettings_edit&mode='+type;
    if(type == 'edit'){
        if(empty(recordid)){
            recordid = ld(obj).attr('tag');
        }
        surl += '&recordid='+recordid;
    }
	var popupobj=CrmPopup.getPopupObj("last");
	var crmPopupobj=CrmPopup.load("","","","LdPopWidth600px",'Settings',"","","","");
	crmPopupobj.prevshow();
	ldAjaxNoProgress(surl,"",function(data){
		if(data.code==1){
			crmPopupobj.setParams(data.result.title,CarouselSettingsSave,"","LdPopWidth600px",'Settings',"",data.result.oktext,"",data.result.canceltext);
			crmPopupobj.mode = type;
            crmPopupobj.show(data.result.content);
            //设置内容最大高度
            crmPopupobj.setPopBodyMaxHeight(".divPopOverflow");
		}
	})
}

//系统设置 - 接口设置 - 轮播图设置 - 保存
function CarouselSettingsSave() {
	var surl = 'index.php?module=ShopSettings&action=ShopSettingsAjax&file=CarouselSettings_save&mode=save';
	var popupobj=CrmPopup.getPopupObj("last");
    var prvemode = popupobj.mode;
    if(prvemode == 'edit'){
        var recordid = ld("#"+popupobj.divid+" [name=recordid]").val();
        surl += '&recordid='+recordid;
        var oldfilename = ld("#"+popupobj.divid+" input[name=upload_img_hidden]").val();
        surl += '&oldfilename='+oldfilename;
    }
    surl += '&prevoperate='+prvemode;
	var linktype = ld("#"+popupobj.divid+" [name=linktype]").val();
    if(linktype == 'Carousel_ProductCategoryList'){
        var linkid = ld("#"+popupobj.divid+" select[name=productcategory]").val();
    }
    else if(linktype == 'Carousel_Productdetails'){
        var fieldname = ld("#"+popupobj.divid+" input[name=selectproductfield]").val();
        var linkid = ld("#"+popupobj.divid+" input[name="+fieldname+"]").val();
        //0048707: (81mis.com/kfbcrm/index.php) 商城设置》轮播图设置》导航链接类型 为产品明细，“*选择产品 ”为必填，但没有提示必填，可直接保存
        if(empty(linkid)||linkid == undefined){
            var confirm_str = arrJsPopLabel['PRODUCTS']+arrJsPopLabel['CANOTEMPTY'];
            RemindsMsg("","LdPopWidth400px",'',"yes","yes",confirm_str);
            return;
        }
    }
    if(ld("#"+popupobj.divid+" [name=carousel_status]").is(':checked')=== true){
        var carousel_status = 'yes';
    }
    else{
        var carousel_status = 'no';
    }
	
	surl += '&linktype='+encodeURIComponent(linktype)+'&linkid='+encodeURIComponent(linkid)
        +'&carousel_status='+encodeURIComponent(carousel_status);
    
    //导航图片判断
    var divid = popupobj.divid;
    var imgfileobj = ld("#"+divid).find(' input[id=upload]');
    var formData = new FormData();
    //新增轮播图时上传图片不能为空
    //wym BUG0072364 上传图片添加删除按钮，编辑页保存也需提示轮播图不能为空
    //wym BUG0075854 【商城设置】轮播图设置列表，编辑导航图片保存时，一直提示“导航图片不能为空”
    if(imgfileobj[0].value == ''&&prvemode != 'edit'){
        var confirm_str = '导航图片'+arrJsPopLabel['CANOTEMPTY'];
        RemindsMsg("","LdPopWidth400px",'',"yes","yes",confirm_str);
        return;
    }
    if(imgfileobj[0].value != ''){
        formData.append("file",imgfileobj[0].files[0]);
    }
    
	ld.ajax({
        url:surl,
        dataType:'json',
        type:'POST',
        data: formData,
        processData : false, // 使数据不做处理
        contentType : false, // 不要设置Content-Type请求头
        success: function(data){
		if(data.code==1){
			popupobj.CancelEvent();
			//刷新列表
			var surl = "index.php?module=ShopSettings&action=CarouselSettings&ReportHeader=dheader&ajax=yes";
			ldAjaxNoProgress(surl,"",function(data){
				if(data.code==1){
					ld(' [name=listcontent]').html(data.result.content);
				}
			})
            DelProgressObjs();
		}else{
			RemindsMsg("","LdPopWidth400px","","yes","yes",data.msg);
            DelProgressObjs();
			return fasle;
		}
        }
	});
}


//轮播图设置，更换导航链接类型触发事件，
function getLinkTypeinfo(obj){
    var popupobj = CrmPopup.getPopupObj('last');
    ld("#"+popupobj.divid).find('tr[id=productcategory_tr]').hide();
    ld("#"+popupobj.divid).find('tr[id=selectproduct_tr]').hide();
    var selectval = ld(obj).val();
    if(selectval == 'Carousel_ProductCategoryList'){
        ld("#"+popupobj.divid).find('tr[id=productcategory_tr]').show();
    }
    else if(selectval == 'Carousel_Productdetails'){
        ld("#"+popupobj.divid).find('tr[id=selectproduct_tr]').show();
    }
}
//轮播图设置，选择图片
function CarouseSelectpicture(obj){
    if (obj.value == '') return true;
    var popupobj = CrmPopup.getPopupObj('last');
    var that = obj;
    var value = that.value;
    //上传文件为图片类型
    if(!/\.(gif|jpg|jpeg|png|bmp|ico|GIF|JPG|JPEG|PNG|BMP|ICO)$/.test(value))
	{
		var confirm_str = value+arrJsPopLabel['CANNOTUOLOAD']+','+arrJsPopLabel['THEALLOWEDTYPES']+'jpg、jpeg、gif、png;';
		RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
		form_ele.value = '';
		return false;
	}
    var name = that.files[0]['name'];
    var size = that.files[0]['size'];
//    var src = window.URL.createObjectURL(that.files[0]);
//    var divobj = ld("#"+popupobj.divid).find(" div[name=div_upload_img]");
//    ld(divobj).find('img[id=img_upload_img]').eq(0).attr('src',src);
//    ld(divobj).find('img[id=img_upload_img]').eq(0).attr('title',name);
    var divobj = ld("#"+popupobj.divid).find(" div[name=div_upload_span]");
    ld(divobj).css('display','block');
    //新增的附件，需要计算附件大小并加上單位
    size = size.toString();
    if(size.indexOf("B")==-1){
        size = parseInt(size);
        if (size < 1024){
            size = size + ' B';
        }
        else if (size > 1024 && size < 1048576){
            size = (size / 1024.0).toFixed(2) + ' KB';
        }
        else if (size > 1048576){
            size = (size / (1024.0 * 1024)).toFixed(2) +' MB';
        }
    }
    ld(divobj).find(' span[name=span_upload_fielname]').html(name);
    ld(divobj).find(' span[name=span_upload_fielsize]').html('('+size+')');
}

//wym BUG0072364 轮播图设置，删除图片
function CarouseDeletepicture(fieldname){
    var popupobj=CrmPopup.getPopupObj('last');
    ld("#"+popupobj.divid+" [name=div_upload_span]").css('display','none');
    if (popupobj != undefined){
        ld("#"+popupobj.divid+" [name=span_"+fieldname+"_fielname]").text('');
    }else{
        ld(" [name=span_"+fieldname+"_fielname]").text('');
    }
    var imgfileobj = ld("#"+popupobj.divid).find(' input[id='+fieldname+']');
    if(imgfileobj[0].value != ''){
        imgfileobj[0].value = '';
    }
    return true;
}

//轮播图设置，选择产品
function showputonproductslist(module,selectmodule,type,PopupButton,obj){
    var url = 'module=ShopSettings&action=ShopSettingsAjax&file=select_putonproducts_popup&ajax=true';
    var returnfieldname = ld(obj).attr('tag');
    url+= '&selectmodule='+selectmodule+'&frommodule='+module+'&type='+type+'&returnfieldname='+returnfieldname;
    //增加商品状态为上架判断标识
    url +='&Carousel_productstatus=true';
    ld.ajax(
    		{
    			type: 'POST',
    			url: "index.php",
                 dataType:'json',
                data:url,
    			success: function(data) {
        			 $("status").style.display="none";
                    
                     if(data.code==1)
    			     {
    			         	var  selectsearchpopupobj=selectSearchPopup.load(data.result.title,"","","LdPopWidth900px",module,"","","","","",selectmodule);
                            selectsearchpopupobj.show(data.result.content);
                            selectsearchpopupobj.selectfieldtype='mainfield';//弹出层界面快速查询
                             if(typeof cls_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined")
                              //通讯录(pc端企业微信要绑定)
                                cls_wxOpenDataobj.bindAllOpenDataByPopupObj(selectsearchpopupobj);
                            //36162: （1.6登录）选择客户弹出层界面：光标应该定位在【查找内容】搜索框中（跟进记录模块测试）
                            ld("#"+selectsearchpopupobj.divid+" [name=pop_search_text]").focus();
                             
    			     }
                    
    			}
    		}
		);
}
//选择产品弹出框--选中产品事件
function CarouselSelectProducs(module,rowid,mid,entityname,fieldname,smownerid,frommodule,spop){
    var popupobj = CrmPopup.getPopupObj('last');
    var prevpopupobj = CrmPopup.getPopupObj('lastprev');
    var prevdivid = prevpopupobj.divid;
    ld("#"+prevdivid+" input[name="+fieldname+"]").val(mid);
    entityname = unescape (decodeURIComponent(entityname));
    ld("#"+prevdivid+" input[name="+fieldname+"_name]").val(entityname);
    ld("#"+prevdivid+" input[name="+fieldname+"_name]").attr("disabled",true);
    ld("#"+prevdivid+" input[name="+fieldname+"_name]").css("cursor",'not-allowed');
    popupobj.CancelEvent();
}

//新增轮播图--清除选择产品
function clear_CarouselSelectfielddata(module,input_id,input_name,fieldname,frommodule,popupselectfield){
    var popupobj=CrmPopup.getPopupObj("last");
    var divid=popupobj.divid;
	var version_account = '';
    var mid = CrmPopup.findHtmlobj(divid,input_id).val();
    var entityname = CrmPopup.findHtmlobj(divid,input_name).val();
    CrmPopup.findHtmlobj(divid,input_name).attr("disabled",false);
    CrmPopup.findHtmlobj(divid,input_name).css("cursor",'');
    CrmPopup.findHtmlobj(divid,input_id).val('');
    CrmPopup.findHtmlobj(divid,input_name).val('');
}

function CarouselSettingsOperate(obj,mode,recordid){
    var surl = 'module=ShopSettings&action=ShopSettingsAjax&file=CarouselSettings_save';
    if(mode==''){
        mode = ld(obj).attr('name');
    }
    if(recordid==''){
        recordid = ld(obj).attr('tag');
    }
    surl +='&mode='+mode+'&recordid='+recordid;
    ldAjax('index.php?',surl,function(data){
		if(data.code==1){
			//刷新列表
			var surl = "index.php?module=ShopSettings&action=CarouselSettings&ReportHeader=dheader&ajax=yes";
			ldAjaxNoProgress(surl,"",function(data){
				if(data.code==1){
					ld(' [name=listcontent]').html(data.result.content);
				}
			})
            DelProgressObjs();
		}else{
			RemindsMsg("","LdPopWidth400px","","yes","yes",data.msg);
            DelProgressObjs();
			return fasle;
		}
	})
}
//商城设置-产品类别设置-操作
function ProductcateSettingsOperate(obj,mode,recordid){
    var surl = 'module=ShopSettings&action=ShopSettingsAjax&ajax=yes&file=ProductcategorySettings_save';
    if(mode==''){
        mode = ld(obj).attr('name');
    }
    if(recordid==''){
        recordid = ld(obj).attr('tag');
    }
    surl +='&mode='+mode+'&recordid='+recordid;
    ldAjax('index.php?',surl,function(data){
        if(data.code==1){
            var surl = "index.php?module=ShopSettings&action=ProductcategorySettings&ReportHeader=dheader&ajax=yes";
            ldAjaxNoProgress(surl,"",function(data){
                if(data.code==1){
                    ld(' [name=listcontent]').html(data.result.content);
                }
            })
            DelProgressObjs();
        }else{
            RemindsMsg("","LdPopWidth400px","","yes","yes",data.msg);
            DelProgressObjs();
            return false;
        }
    })
}
//商城设置 - 小程序商城设置 - 客服电话-编辑
function PhoneSettings_edit(obj,type,recordid){
    
	var surl = 'index.php?module=ShopSettings&action=ShopSettingsAjax&file=PhoneSettings_edit&mode='+type;
    //为请求加上判断是新增还是编辑的字段
    if(type == 'edit'){
        if(empty(recordid)){
            recordid = ld(obj).attr('tag');
        }
        surl += '&recordid='+recordid;
    }
	var popupobj=CrmPopup.getPopupObj("last");
	var crmPopupobj=CrmPopup.load("","","","LdPopWidth600px",'Settings',"","","","");
	crmPopupobj.prevshow();
	ldAjaxNoProgress(surl,"",function(data){
		if(data.code==1){
			crmPopupobj.setParams(data.result.title,PhoneSettingsSave,"","LdPopWidth600px",'Settings',"",data.result.oktext,"",data.result.canceltext);
			crmPopupobj.mode = type;
            crmPopupobj.show(data.result.content);
            // 设置内容最大高度
            crmPopupobj.setPopBodyMaxHeight(".divPopOverflow");
		}
	})
}

//商城设置 - 小程序商城设置 - 客服电话 - 保存
function  PhoneSettingsSave() {
	var surl = 'index.php?module=ShopSettings&action=ShopSettingsAjax&file=PhoneSettings_save&mode=save';
	var popupobj=CrmPopup.getPopupObj("last");
    var prvemode = popupobj.mode;
    if(prvemode == 'edit'){
        var recordid = ld("#"+popupobj.divid+" [name=recordid]").val();
        surl += '&recordid='+recordid;
    }
    //获取姓名与电话的input的值以及复选框的checked
    var phonename = ld('#'+popupobj.divid+" [tag=PhoneNameEdit]").val();
    var phonenumber = ld('#'+popupobj.divid+" [tag=PhoneNumberEdit]").val();
    var phonestatus = ld('#'+popupobj.divid+" [tag=PhoneStatus]").prop('checked') == true?'yes':'no';
    var reg = /^\s+$/g;
    var test = reg.test(phonename);
    surl += "&phone_status="+phonestatus;
    surl += "&phone_name="+phonename;
    surl += "&phone_number="+phonenumber;
    var onInput;
    //保证输入的姓名与电话不为空
    //230703 wym BUG0069002 输入的联系人姓名不能全部为空格
    if(phonename == ''|| test==true){
        var confirm_str = arrJsPopLabel['NAMECHECK'];
        MessagePopup.TipZero_error(confirm_str);
        ld('#'+popupobj.divid+" [tag=PhoneNameEdit]").focus();
        ld('#'+popupobj.divid+" [tag=PhoneNameEdit]").addClass('border_red1');
        setTimeout(function(){
            ld('#'+popupobj.divid+" [tag=PhoneNameEdit]").removeClass('border_red1');
        },1000);
        return;
    }
    if(phonenumber == '' && phonename != ''){
        var confirm_str = arrJsPopLabel['PHONECHECK'];
        // console.log(confirm_str);
        MessagePopup.TipZero_error(confirm_str);
        ld('#'+popupobj.divid+" [tag=PhoneNumberEdit]").focus();
        ld('#'+popupobj.divid+" [tag=PhoneNumberEdit]").addClass('border_red1');
        setTimeout(function(){
            ld('#'+popupobj.divid+" [tag=PhoneNumberEdit]").removeClass('border_red1');
        })
        return;
    }
    //对输入的电话号码进行正则判断
    var regTel = /^(400)(-(\d{3,4}))(-(\d{3,4}))$/.test(phonenumber);//400开头的电话
    var regTel1 = /^(([0\+]\d{2,3}-)?(0\d{2,3})-)(\d{7,8})(-(\d{3,}))?$/.test(phonenumber);//带区号的固定电话
    var regTel2 = /^(\d{7,8})(-(\d{3,}))?$/.test(phonenumber);//不带区号的固定电话 
    var regTel3 = /^(\d{8,11})?$/.test(phonenumber);//不带-号的手机号
    if(!regTel&&!regTel1&&!regTel2&&!regTel3)
    {
        var confirm_str = arrJsPopLabel['CORRECTPHONEFORMAT']+'!';
        RemindsMsg("","LdPopWidth400px",'',"yes","yes",confirm_str);
        return;
    }
    ldAjax(surl,'',function(data){
        DelProgressObjs();
		if(data.code==1){
            // console.log(data)
			popupobj.CancelEvent();
			//刷新列表
			ld(' [name=listcontent]').html(data.result.content);
		}else{
			RemindsMsg("","LdPopWidth400px","","yes","yes",data.msg);
			return fasle;
		}
    })
}


function PhoneSettingsOperater(obj,mode,recordid){  //gxj 230706 BUG0069165 点击上移下移，以及是否显示字段，弹出提示信息错误（不应弹出提示信息）
    var surl = 'module=ShopSettings&action=ShopSettingsAjax&file=PhoneSettings_save';
    surl += '&mode=' + mode + '&recordid=' + recordid;
    ldAjax('index.php?', surl, function (data) {
        ld(obj).attr('repeat', 'yes');
        if (data.code == 1) {
            //刷新列表
            ld(' [name=listcontent]').html(data.result.content);
            DelProgressObjs();
        } else {
            RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", data.msg);
            DelProgressObjs();
            return false;
        }
    })
}
function PhoneSettingsOperate(obj,mode,recordid) {

    if (mode == '') {
        mode = ld(obj).attr('name');
    }
    if (recordid == '') {
        recordid = ld(obj).attr('tag');
    }
    var repeat = ld(obj).attr('repeat');
    if (repeat == 'no') {
        return;
    }
    ld(obj).attr('repeat', 'no');

    if (mode == 'delete') {
         var str = arrJsPopLabel['SUREWANTDELETE'];//gxj 230705 BUG0069050 删除时应弹出确认信息
         RemindsMsg("","LdPopWidth400px","","yes","yes",str);
        //确定按钮
          ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function() {
              PhoneSettingsOperater(obj,mode,recordid);
          })
    } else {
        PhoneSettingsOperater(obj,mode,recordid);
    }
}


