(function($) {
    $.fn.resizableColumns = function(tableid,report_id,createObj) {
        var isColResizing = false;
        var resizingPosX = 0;
        var tablejsdom = $('#'+ createObj.divid + ' #' +tableid)[0];//表格jsdom  之前是用document.getelementByid()获得 但是详情页点编辑  页面上有两个表格一个的id  重复了
        var _table_header = $(this).find('thead');
        var tableobj=$(this);
        var _thead = $(this).find('thead').first();
        tableobj.find('th').each(function() {
            //保证这个th里面只有一个resizer的div
            $(this).find('.resizer').remove();
            //$(this).css('position', 'relative');
            if ($(this).is(':not(.no-resize)')) {
                // if ($(this).nextAll('th.no-resize').length < $(this).nextAll('th').length) {
                    $(this).append("<div class='resizer' style='position:absolute;top:0px;right:-3px;bottom:0px;width:6px;z-index:999;background:transparent;cursor:col-resize'></div>");
                // }
            }
        })
        $(document).unbind("mouseup").bind("mouseup",function(e) {
             isColResizing = false;
            _thead.find('th').css('cursor','default');
             _thead.find('th').removeClass('resizing');
        });
        $(tableobj).unbind("mouseleave").bind("mouseleave",function(e) {
             isColResizing = false;
             
             _thead.find('th').css('cursor','default');
              _thead.find('th').removeClass('resizing');
        });
       
        $(tableobj).unbind("mouseup").bind("mouseup",function(e) {
            _thead.find('th').css('cursor','default');
            _thead.find('th').removeClass('resizing');
           
            isColResizing = false;
            e.stopPropagation();
            //鼠标拿起 计算每一列的宽度 存储到数据库
            var header_Tds;
            var header_length;

            // if(tablejsdom!=undefined){
            if(tablejsdom!=undefined){
                header_Tds = tablejsdom.rows[0].cells;
                header_length = header_Tds.length ;//th个数

                //thResizableContent
                var header_TdsContent = tablejsdom==undefined?null:tablejsdom.rows[0].cells;


                var str_width='';

                for(var i=0;i<header_length;i++){
                    if(header_Tds[i].style.width!=''){
                        str_width+=parseInt(header_Tds[i].style.width)+",";
                        if(header_TdsContent!=null){
                            header_TdsContent[i].style.width = header_Tds[i].style.width;
                        }
                    }else{
                        str_width+="-1,";
                    }
                }
                var params = {};
                params.report_id = report_id;
                params.str_width = str_width;
                createObj.str_width_str = str_width
                var url = 'index.php?module='+createObj.pageto_module+'&action='+createObj.pageto_module+'Ajax&file=CustomTablesEditView&function_name=saveResizeData';
                //将宽度传输到后台 存储到数据库中
                $.ajax({
                    url: url,
                    type: 'POST',
                    data:params,
                    dataType:'json',
                    async: true,
                    timeout: 70000,
                    success: function(data)
                    {
                        // console.log(arrJsPopLabel['WidthData']);
                    }
                })
            }
        });

        $(_table_header).find("th").find('.resizer').mousedown(function(e) {
            $(this).css('cursor','col-resize');
            if (e.button == 0) {
                _thead.find('th').removeClass('resizing');
                $(_thead).find('tr:first-child th:nth-child(' + ($(this).closest('th').index() + 1) + ') .resizer').closest('th').addClass('resizing');
                resizingPosX = e.pageX;
                isColResizing = true;
            }
            e.stopPropagation();
        }).click(function(e) {
            return false;
        })

        $(_table_header).find("th").mousemove(function(e) {
            window.getSelection ? window.getSelection().removeAllRanges() : document.selection.empty();
             e.stopPropagation();
            if (isColResizing) {
                  
                var _resizing = _thead.find('th.resizing .resizer');
                
                if(tablejsdom!=undefined) {
                    var tableObj = tablejsdom==undefined?null:tablejsdom;
                    var header_TdsContent = tablejsdom==undefined?null:tablejsdom.rows[0].cells;
                    var contentThisIndex = _resizing.closest('th').index();
                    var contentNextIndex = _resizing.closest('th').index()+1;

                }
                if (_resizing.length == 1) {
                    var _nextRow = _thead.find('th.resizing + th');
                    if (_nextRow.hasClass('no-resize')) {
                        _nextRow = _nextRow.next('th:not(.no-resize)');

                    }
                    var _nextRow_thindex =_nextRow.attr('thindex');

                    var _pageX = e.pageX || 0;
                    var _widthDiff = _pageX - resizingPosX;
                    var _setWidth = _resizing.closest('th').innerWidth() + _widthDiff;
                    var all_width = $(tableObj).css('width');
                    all_width = parseInt(all_width) + parseInt(_widthDiff);
                    //var _nextRowWidth = _nextRow.innerWidth() - _widthDiff;
                    var oldwidth=parseInt(_resizing.closest('th').innerWidth());
                    var nextrow_left = _nextRow.css('left');
                    var nextrow_position = _nextRow.css('position');
                    nextrow_left = parseInt(nextrow_left);
                    if (resizingPosX != 0 && _widthDiff != 0  ) {
                        _resizing.closest('th').innerWidth(_setWidth);
                        
                        // if(parseInt(_resizing.closest('th').innerWidth())==oldwidth)
                        // {
                        //     return ;
                        // }
                        resizingPosX = e.pageX;
                        //_nextRow.innerWidth(_nextRowWidth);
                        if(tablejsdom!=undefined) {
                            header_TdsContent[contentThisIndex].style.width = _setWidth+'px';
                            $(header_TdsContent[contentThisIndex]).find('[name="header_width[]"]').val(_setWidth);
                            /*if(nextrow_position=='sticky'){
                                nextrow_left = parseInt(nextrow_left)+parseInt(_widthDiff);
                                _nextRow.css('left',nextrow_left+'px');//下一个元素的left值  仅粘贴定位需要
                                ld.each(ld('#'+tableid).find('td[tdindex='+_nextRow_thindex+']'),function(i,tdobj){
                                    ld(tdobj).css('left',nextrow_left+'px');
                                });
                            }*/
                            //列固定 仅粘贴定位需要
                            if(nextrow_position=='sticky') {
                                var width = freezecolumnsObj.freezeThColumnBeforeAll('set-sticky');
                                freezecolumnsObj.freezeTdColumnBeforeAll('set-sticky',width);
                            }
                        }
                        $(tableObj).css('width',all_width+'px');
                    }
                }
            }
        })
    };
}
(jQuery))
