{*zxm20221212 新的基本查找组件*}
<div id="basicsearchcolumns_real" style="width:112px;">
    {*onchange事件  去获取基本查找历史*}
    <select name="search_field" onchange="getBasicFieldSearchHistory(this); setBasicFieldStorage(this); changeBasicFieldplaceholder(this);" id="bas_searchfield" class="commonSelectPop gwidth100 overflow-space" style="border-radius: 4px 0 0 4px;border-right:none;" >
        {if $MODULE != 'ChannelCode'}<option value="all">{'AllFields'|@getFixedLabel}</option>{/if}
{*        {html_options options=$SEARCHLISTHEADER }*}
        {*BUG20240816-03 ls 240821 基本搜索查询全部字段，查询不到结果(标签启用时不支持标签查找，暂时这样处理)*}
        {foreach key=key item=searchcolumn from=$SEARCHLISTHEADER}
            {if $key|stripos:'tag:tag' eq false}
            <option value="{$key}" {if $key eq $basicLastSearchFieldName}selected{/if}>{$searchcolumn}</option>
            {/if}
        {/foreach}
    </select>
    <input type="hidden" name="searchtype" value="BasicSearch">
</div>
<div class="ld-listview-basicsearch">
    <!--zxm 20230807 升级到"客户" 搜索的时候 会从双引号处截断 所以加htmlspecialchars处理-->
    <input type="text" class="commonSelectPop gwidth100 padR40" onkeyup="basicFieldSearchSubmit(event)" 
        onclick="getBasicFieldSearchHistory(this)" name="search_text" value="{if $SEATCH_INPUT.search_text != ''}{$SEATCH_INPUT.search_text|htmlspecialchars}{/if}"
        autocomplete="off" style="border-radius: 0 4px 4px 0;padding-right:40px;">
    <b style="position: absolute;right:30px;top:0;cursor: pointer" class="ld-icon-clearsearch" onclick="clearBasicSearch(this);"></b>
    {if $MODULE=='RecycleBin'}
        <div class="positionFirst" onclick="Recyle_callSearch('Basic');">
            <i class="ld-fonticon ld-fonticon-search hlineheight30"></i>
        </div>
    {else}
        <div class="positionFirst" onclick="callSearch('Basic');">
            <i class="ld-fonticon ld-fonticon-search hlineheight30"></i>
        </div>
    {/if}
    <div style="position: absolute;right:0;top:30px;width:100%;background-color: #fff;z-index:902;">
        <ol class="D_more_menua_searchbtn" id="basicSearchList">
        </ol>
    </div>
</div>
<script>
    var module = '{$MODULE}';
    setShowOrHideClearIcon();
    if(empty(ld('#basicSearchNewDiv').find('[name=search_text]').val())){
        ld('#basicSearchNewDiv').find('[name=search_text]').focus();
    }else{
        ld('#basicSearchNewDiv').find('[name=search_text]').data('tempvalue',ld('#basicSearchNewDiv').find('[name=search_text]').val());
        ld('#basicSearchNewDiv').find('[name=search_text]').val('').focus().val(ld('#basicSearchNewDiv').find('[name=search_text]').data('tempvalue'));
    }

    //zxm 20221205 新的基本查找方法--选择字段获取搜索历史
    function getBasicFieldSearchHistory(obj){
        // var fieldinfo = ld(obj).val();
        //var basickeywords = ld('#basicSearchNewDiv').find('[name=search_text]').val();
        //显示清除按钮\
        setShowOrHideClearIcon();
        var popupobj=CrmPopup.getPopupObj('last');
        if (popupobj.type=='selectsearchdetail'){
            var selectmodule=popupobj.module;
        }else {
            var selectmodule=module;
        }
        var url = 'index.php?module='+selectmodule+'&action='+selectmodule+'Ajax&file=SearchHistory&mode=showhistory&newbasicsearch=yes';
        url += '&searchtype=BasicSearch';
        url += '&searchfrom='+popupobj.type;
        //zkt 20220513 51745（https://81mis.com/kfbcrm/index.php）审批中心》合同订单，点击查找按钮，界面一直转圈
        if(selectmodule == 'Approve'){
            url += '&searchmodule='+selectmodule;
        }
        if(selectmodule == 'RecycleBin'){
            return false;
        }

        if (obj.tagName.toLowerCase() === 'input') {
            var optionvalues = ld(obj).parent().prev(' #basicsearchcolumns_real').find('select#bas_searchfield option').map(function() {
                return ld(this).val();
            }).get();
        }
        else if (obj.tagName.toLowerCase() === 'select') {
            var optionvalues = ld(obj).find(' option').map(function() {
                return ld(this).val();
            }).get();
        }

        ldAjax(url,"",function(data){
            DelProgressObjs();
            if(data.code == 1){
                var searchvalue_arr = data.result.searchvalue_arr;
                var clearlabel = data.result.clearlabel;
                var html = '';
                ld.each(searchvalue_arr,function(i,item){
                    if (optionvalues.includes(item.searchvalue.search_field)) {
                        html += '<li class="active-result" name="BasicSearch_result_'+i+'"  onclick="selectThisHistoryLine(this);return false;">'+
                            '<a class="overflow-space" optionvalue="'+item.searchvalue.search_field+'" searchtext="'+item.searchvalue.search_text+'" title="'+item.label+'">'+item.label+'</a>'+
                            '</li>';
                    }
                });
                if (popupobj.type == 'selectsearchdetail'){
                    html += '<li name="clear_BasicSearch" searchtype="BasicSearch" onclick="advanceFilterSearch.getInstance().clearhistoryNew(this)" onmouseover="cmb_limouseover(event,\'BasicSearch\',\'\')"><a class="overflow-space blueFont">'+clearlabel+'</a></li>';
                }else {
                    html += '<li name="clear_BasicSearch" searchtype="BasicSearch" onclick="clearhistory(this)" onmouseover="cmb_limouseover(event,\'BasicSearch\',\'\')"><a class="overflow-space blueFont">'+clearlabel+'</a></li>';
                }
                ld("#"+popupobj.divid+' #basicSearchNewDiv').find('#basicSearchList').html(html);

                var curr_idx = -1;
                ld("#"+popupobj.divid+' #basicSearchNewDiv').find('[name="search_text"]').off('keydown').on('keydown',function (event){
                    var liobj = ld("#"+popupobj.divid+' #basicSearchNewDiv').find('#basicSearchList li');
                    if(event.keyCode == 40 || event.keyCode == 38){
                        event.preventDefault();
                        if(liobj.length > 0){
                            if(event.keyCode == 40){
                                if(curr_idx < liobj.length - 1){
                                    curr_idx++;
                                    liobj.removeClass('result_li');
                                    liobj.eq(curr_idx).addClass('result_li');
                                }
                            }
                            else{
                                if(curr_idx > 0){
                                    curr_idx--;
                                    liobj.removeClass('result_li');
                                    liobj.eq(curr_idx).addClass('result_li');
                                }
                            }
                        }
                    }
                    else if(event.keyCode == 13 || event.keyCode == 32){
                        if(curr_idx > -1){
                            liobj.eq(curr_idx).click();
                        }
                    }
                });
                ld('body').unbind('click').bind('click',function(){
                    ld("#"+popupobj.divid+' #basicSearchNewDiv').find('#basicSearchList').html('');
                });
            }else{
                ld("#"+popupobj.divid+' #basicSearchNewDiv').find('#basicSearchList').html('');
            }
            /*

             getJsScript("include/js/cls_ShortKey.js",function(){

               if(popupobj.basesearchshortkeyobj==undefined)
               {

                    popupobj.basesearchshortkeyobj=new cls_ShortKey(popupobj)
               }
                var shortkeyobj=popupobj.basesearchshortkeyobj;
                var TriggerDirectionobj=ld(obj);
                shortkeyobj.setSelectedClassName("result_li");

                var directionparentobj=ld("#basicSearchList");

                shortkeyobj.setEventByTag(TriggerDirectionobj,directionparentobj,"li",function(event,selectobj){

                    BasicSearch_limouseover(selectobj);

                }, undefined)
            })*/



            //BasicSearch_limouseoverEvent();
        });


    }
    //模糊搜索报表 回车搜索 zxm 20221206 新的基本查找方法--键盘抬起的事件
    function basicFieldSearchSubmit(event){
        var e = event || window.event;
        if(e.keyCode == 13){
            var popupobj=CrmPopup.getPopupObj('last');
            ld('#'+popupobj.divid+' #basicSearchNewDiv').find('#basicSearchList').html('');
            // Enter 回车键
            //搜索
            if(module == 'RecycleBin'){
                Recyle_callSearch('Basic');
            }else{
                callSearch('Basic');
            }
        }
        setShowOrHideClearIcon();
    }

    //模糊搜索报表 回车搜索 zxm 20221206 新的基本查找方法--搜索历史选中事件
    function selectThisHistoryLine(obj){
        var popupobj=CrmPopup.getPopupObj('last');
        var searchtext = ld(obj).find('a').attr('searchtext');
        var optionvalue = ld(obj).find('a').attr('optionvalue');
        ld('#'+popupobj.divid+' #basicSearchNewDiv').find('[name=search_text]').val('').focus().val(searchtext);
        ld('#'+popupobj.divid+' #basicSearchNewDiv').find('#bas_searchfield').val(optionvalue);
        ld('#'+popupobj.divid+' #basicSearchNewDiv').find('#basicSearchList').html('');
        //搜索
        if (popupobj.type == 'selectsearchdetail'){
            fun_setCrmPopupWindow.callSearch('Basic');
        }else if (popupobj.type == 'relatelistpage'){
            if (popupobj.headermodule == 'PriceBooks' && popupobj.module == 'Products'){
                fun_ProductPriceBooks.getInstance().searchRelatedProducts();
            }
        }
        else{
            if(module == 'RecycleBin'){
                Recyle_callSearch('Basic');
            }else{
                callSearch('Basic');
            }
        }
    }
    //判断 清除按钮是否显示
    function setShowOrHideClearIcon(popupobj=''){
        var basicSearchNewDiv_Obj;
        if(!empty(popupobj)){
            basicSearchNewDiv_Obj = ld('#'+popupobj.divid+' #basicSearchNewDiv');
        }else{
            basicSearchNewDiv_Obj = ld('#basicSearchNewDiv');
        }
        var search_text = basicSearchNewDiv_Obj.find('[name=search_text]').val();
        //显示清除按钮\
        if(!empty(search_text)){
            basicSearchNewDiv_Obj.find('.ld-icon-clearsearch').show();
        }else{
            basicSearchNewDiv_Obj.find('.ld-icon-clearsearch').hide();
        }
    }

    //清除 zxm 20221212
    function clearBasicSearch(obj){
        ld('#basicSearchNewDiv').find('[name=search_text]').val('');
        ld('#basicSearchNewDiv').find('.ld-icon-clearsearch').hide();
        ld('#basicSearchNewDiv').find('[name=search_text]').focus();
        /*if(module == 'RecycleBin'){
            Recyle_callSearch('Basic');
        }else{
            callSearch('Basic');
        }*/
    }

    //xll 20221214 保存最近一次的基本搜索框字段选项，将其设为基本搜索框的默认值
    function setBasicFieldStorage(obj){
        var storage_value = ld(obj).val();
        var url = 'index.php?module='+module+'&action='+module+'Ajax&file=fieldstorage&storage_value='+storage_value;
        ldAjaxNoProgress(url,"",function(data){
        });
    }
    var fieldvalue = '{$SEATCHFIELDSTORAGE}';
    if(fieldvalue != ''){
        var tmp_array = fieldvalue.split(':');
        var tmp_fieldvalue = (tmp_array.length > 1) ? tmp_array[1]:tmp_array[0];
        var newfieldvalue = ld('#bas_searchfield').find('option[value *= '+tmp_fieldvalue+']').val(); //模糊匹配
        //wym 240103 BUG0076993 切换查询分类，基本查找的搜索字段变为空，应默认下拉框内第一个字段
        if(newfieldvalue!=undefined && newfieldvalue!='undefined' && newfieldvalue!=''){
            ld('#bas_searchfield').val(newfieldvalue);
        }
        //ld('#bas_searchfield').val(fieldvalue); //直接赋值会导致更换分类后下拉框的值随之更换
    }
    // txy XUQIU1001546 为搜索框增加聚焦事件 单据序时簿列表界面的基本查找
    ld('#basicSearchNewDiv .ld-listview-basicsearch input').unbind('focus').bind('focus',function(){
        ld('#basicSearchNewDiv #basicSearchNewDiv #basicsearchcolumns_real select').addClass('ld-border-color-3b7cff');
        ld(this).addClass('ld-border-color-3b7cff');
    });
    ld('#basicSearchNewDiv .ld-listview-basicsearch input').unbind('blur').bind('blur',function(){
        ld('#basicSearchNewDiv #basicSearchNewDiv #basicsearchcolumns_real select').removeClass('ld-border-color-3b7cff');
        ld(this).removeClass('ld-border-color-3b7cff');
    });
    // wym 231229 BUG0078108 要等select选中项改为历史数据选中项后,再调changeplaceholder事件
    changeBasicFieldplaceholder(ld('#basicsearchcolumns_real').find('[name=search_field]'));

    /*function BasicSearch_limouseoverEvent(){
        var liobj=ld('#basicSearchNewDiv #basicSearchList').find('li');
        ld(liobj).unbind('mouseover').mouseover(function (){

            BasicSearch_limouseover(ld(this))

        });
    }*/

    /*function BasicSearch_limouseover(selectlibobj)
    {
        var liobj=ld('#basicSearchNewDiv #basicSearchList').find('li');
        ld(liobj).attr("class","");
        ld(selectlibobj).addClass('result_li');

    }*/
    //wym XUQIU1001090 单据序时簿列表界面，基本查找增加“全部字段”功能
    function changeBasicFieldplaceholder(obj){
        var selected_field_label = ld(obj).find('option:selected').text();
        if(ld(obj).val() == "all"){
            var placehoder_text = arrJsPopLabel['SearchAllFieldsInTheListBelow'];
        }
        else{
            //wym 240603 BUG20240603-09 基本查找,搜索框也需要增加提示语信息：“多个值用|隔开”
            //wym 240604 BUG20240604-43 快速搜索输入框提示信息显示不完整 去掉搜索某字段的提示
            var placehoder_text = /*arrJsPopLabel['SEARCHCAPITAL']+selected_field_label+"，"+*/arrJsPopLabel['SEARCHBELONGTIP'];
        }
        ld('#basicSearchNewDiv .ld-listview-basicsearch input').attr('placeholder',placehoder_text);
    }
</script>