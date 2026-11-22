(function($) {
    $(function() {
        var BASE_URL = 'http://'+loginurl+'/app';
        var SERVER_URL = 'http://'+loginurl+'/mobileindex.php?module=Home&action=ListView&method=saveAttachmentFile&phoneversion=ios';
            SERVER_URL += "&category="+category+"&userid="+userid+"&ajax=yes&responseType=htmlfive&appversion="+mobileVersion;
        // 初始化Web Uploader
        var uploader = WebUploader.create({
            // swf文件路径
            // 文件接收服务端。'http://webuploader.duapp.com/server/fileupload.php'
            server: SERVER_URL,
            // 选择文件的按钮。可选。
            // 内部根据当前运行是创建，可能是input元素，也可能是flash.
            pick: '#picker',
            // 不压缩image, 默认如果是jpeg，文件上传前会压缩一把再上传！
            // resize: false,
        }).on('fileQueued', function( file ) {
            var att_count = ViewObj.rootScope.att_count;
            att_count++;
            if(att_count>ViewObj.rootScope.att_maxcount){
                PopPromptBox.show('添加的附件数量不允许超出'+ ViewObj.rootScope.att_maxcount +'个');
                return;
            }
            ViewObj.rootScope.att_count = att_count;
            var img = Tools.getAttImg(file.name);
            var html =  '<div id="' + file.id + '" class="item-content">' +
                            '<div class="media-list">' + 
                            '    <img style="width:36px;height:36px;" src="images/' + img + '.png">' + 
                            '</div>' + 
                            '<div class="item-inner">' + 
                            '    <div class="item-title"></div>' + 
                            '    <div class="item-text"></div>' + 
                            // '    <div class="item-title">' + file.name + '</div>' + 
                            // '    <div class="item-text">' + file.size + '</div>' + 
                            '</div>' + 
                            '<div class="media-list-right">' + 
                            '    <img tag="del" style="width:24px;height:24px;" src="images/del.png">' + 
                            '</div>' + 
                        '</div>';
            ld("#thelist").append(html);
            uploader.upload();
        });

        // 文件上传进度
        // 文件上传中，Web Uploader会对外派送uploadProgress事件，其中包含文件对象和该文件当前上传进度。
        uploader.on('uploadProgress', function( file, percentage ) {
            var $li = ld( '#'+file.id ),
                $percent = $li.find('.progress .progress-bar');

            // 避免重复创建
            if ( !$percent.length ) {
                $percent =  ld( '<div class="progress progress-striped active">' +
                                    '<div class="progress-bar" role="progressbar" style="width: 0%"></div>' +
                                '</div>').appendTo( $li ).find('.progress-bar');
            }
            $li.find('.media-list-right').text('上传');

            $percent.css( 'width', percentage * 100 + '%' );
        });

        // 文件成功、失败处理
        // 文件上传失败会派送uploadError事件，成功则派送uploadSuccess事件。不管成功或者失败，在文件上传完后都会触发uploadComplete事件。
        uploader.on('uploadSuccess', function( file,data ) {
            var rest = data._raw;
            var restobj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest);
            var arr1 = [];
            arr1['id'] = file.id;
            arr1['name'] = restobj.result.filename;
            arr1['path'] = restobj.result.filepath;
            arr1['ext'] = file.ext;
            arr1['size'] = restobj.result.filesize;
            arr1['type'] = file.type;
            var arr2 = [];
            if(ViewObj.rootScope.att_arr != undefined){
                arr2 = ViewObj.rootScope.att_arr;
            }
            arr2.push(arr1);
            ViewObj.rootScope.att_arr = arr2;

            var img = Tools.getAttImg(restobj.result.filename);
            if(img == 'img'){
                var imgStr = '<img style="width:36px;height:36px;border-radius:.3rem;" src="http://' + loginurl + '/' + restobj.result.filepath + restobj.result.filename + '">';
                ld( '#'+file.id ).find('.media-list').html(imgStr);    
            }
            var delStr = '<img tag="del" style="width:24px;height:24px;" src="images/del.png">';
            ld( '#'+file.id ).find('.item-title').text(restobj.result.filename);
            ld( '#'+file.id ).find('.item-text').text(restobj.result.filesize);
            ld( '#'+file.id ).find('.media-list-right').html(delStr);
        });

        uploader.on('uploadError', function( file ) {
            ld( '#'+file.id ).find('h4.info a.ios_attright').text('上传出错');
        });

        uploader.on('uploadComplete', function( file ) {
            ld( '#'+file.id ).find('.progress').fadeOut();
        });
    });
})(jQuery);