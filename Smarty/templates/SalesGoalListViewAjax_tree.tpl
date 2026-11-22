<!--中间-->

<div id="container_treediagram" >
    <div class="salesgoaltips">
        <ul>
            <li><i class="complete"></i><span>{"COMPLETIONVALUE"|@getFixedLabel}</span></li>
            <li><i class="tolook"></i><span>{"TOLOOKVALUE"|@getFixedLabel}</span></li>
            {if $MODULELOOK eq 'accountsnumber'}
                <li style="color:#999;">（{"NUMBEROFCUSTOMERS"|@getFixedLabel}）</li>
            {else}
                <li style="color:#999;">（{"AMOUNTUNIT"|@getFixedLabel}）</li>
            {/if}
        </ul>
    </div>
</div>
<div class="salesgoaltips2" id="salesgoaltips2">
    <img class="save_iamge" src="themes\images\save_as_image.png" alt="" style="" onclick="savepicture()">
    <label class="save_iamge_label" style="">{"SAVEASIMAGE"|@getFixedLabel}</label>
</div>
<script type="text/javascript" src="include/js/dom_to_image.js"></script>
<script>
    ld(".save_iamge").mouseover(function(){
        ld(".save_iamge_label").css("display","block");
    })
    ld(".save_iamge").mouseout(function(){
        ld(".save_iamge_label").css("display","none");
    })
    function savepicture(){
        var imageWidth = document.getElementById('container_treediagram').scrollWidth;
        var imageHeight = document.getElementById('container_treediagram').scrollHeight;
        domtoimage.toPng(document.getElementById('container_treediagram'),{
            useCORS: true,//开启跨域配置
            width: imageWidth+30,//图片宽度
            height: imageHeight+30,//图片高度
            x: window.pageXOffset,//x轴起点
            y: window.pageYOffset,//y轴起点
            bgcolor: '#fff'//图片背景色
        })
        .then(function(dataUrl) {
            var alink = document.createElement("a");
    		alink.href = dataUrl;
    		alink.download = arrJsPopLabel['TREECHATSALESGOAL'];//fileName保存提示中用作预先填写的文件名
            //document.body.appendChild(alink);
            alink.click();
        })        
    }
    
</script>
<script>
    //设置高度
    var a = ld(' #resize_content_table_divid').outerHeight(true);//头部高度
    ld('#container_treediagram').css('height',a-100-30);
    //edit:can 2020-10-20 042935: （61mis.com/WX/kh41215/ ）(企业微信PC端)销售管理-销售目标（TOPBON客户001增强版）；点开销售管理-销售目标后，页面一直转圈；珞落计划crm企业微信PC端-工具-销售目标 也存在此状况
    var   data = {$treeValue};
    ld('#container_treediagram').orgchart({
        'data' : data,
        'direction':'l2r',
        // 'zoom':1, //通过鼠标滚轮放大或缩放OrgChart
        // 'pan':1,//通过鼠标拖放来控制OrgChart
        'zoominLimit':3, //设置放大限制

    });
    ld(function(){
        if(data.children.length <3){
            ld(" .orgchart").css({
                "margin-top":"100px",
            })
        }
        resize_view()
    })
    function resize_view(){
        var ww = ld(" .orgchart").width();
        if(ww <300){
            ld(" .orgchart").css({
                "margin-top":"100px",
            })
        }
    }
    /*ld(window).resize(function(){
        resize_view();
    })*/
        
        async function initCanvas(ids) {
        var canvasname = [];
        if (parent.WWOpenData.initCanvas) {
            parent.WWOpenData.initCanvas();
        }
        if (parent.WWOpenData.prefetch) {
            var items = [];
            ld.each(ids, function (index, item) {
                items.push({ type: 'departmentName', id: item });
            });
            const result = await new Promise((resolve, reject) => {
                parent.WWOpenData.prefetch({ items }, (err, data) => {
                    if (err) {
                        return reject(err);
                    }
                    resolve(data);
                })
            });
            // 拿到渲染数据
            result.items.map((v) => {
        console.log(v);
                canvasname.push(v.data);
            });
        }
        return canvasname;
    }
    
 
var groupids = {$groupids};console.log(groupids);
if(iskehu001 == 'yes'){
    data1 = initCanvas(groupids);
    console.log(data1);
}
</script>
{*/***}
{*data【json or String】：数据*}
{*pan 【boolean 默:flase】：通过鼠标拖放来控制OrgChart*}
{*zoom【boolean 默:false】：通过鼠标滚轮放大或缩放OrgChart*}
{*zoominLimit【number 默:7】：设置放大限制*}
{*zoomoutLimit【number 默:0.5】：设置缩放限制*}
{*direction【String 默:t2b】：T2B："从上到下"，B2T："从底到上"，L2R："左到右"，R2L："向左到右"*}
{*verticalLevel【integer(>=2)】：*}
{*toggleSiblingsResp【boolean 默:false】：通过单击左/右箭头分别显示/隐藏左/右兄弟节点*}
{*ajaxURL【json】：不同的优先级提供了发送不同节点的Ajax请求的URL*}
{*visibleLevel【number】：默认展开几级*}
{*nodeId【String 默:id】：将数据源的一个属性设置为每个OrgChart节点的唯一标识符。*}
{*nodeTitle【String 默:name】：将数据源的一个属性设置为OrgChart节点标题段的文本内容*}
{*nodeContent【String】：将数据源的一个属性设置为OrgChart节点的内容部分的文本内容。*}
{*nodeTemplate【function】：它是一个模板生成函数，用于定制任何复杂的节点内部结构*}
{*createNode【function】：它是用于自定义每个OrgCad节点的回调函数*}
{*parentNodeSymbol【String 默:fa-users】：使用图标暗示该节点有子节点*}
{*exportButton【boolean 默:false】：是否启用OrgChar的导出按钮*}
{*exportFilename【String 默:OrgChart】：当输出当前的OrgChart作为图片时，它是文件名。*}

{*exportFileextension【String 默:png】：可用的值是PNG和PDF。*}

{*chartClass【String】：当你想在一个页面上实例化多个orgcharts 时，你应该添加不同的类名来区分它们。*}

{*draggable【boolean 默:false】：用户可以拖动和删除OrgChart节点*}

{*dropCriteria【function】：用户可以构造自己的标准来限制拖动节点和删除区域之间的关系*}

{*initCompleted【function】：经常知道您的表何时已经完全初始化、数据加载和呈现，尤其是当使用Ajax数据源时*}