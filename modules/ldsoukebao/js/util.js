function Skb_Ajax(params, callback) {

    //后台hrl
    var location = window.location;
    // 分割路径来获取动态部分
    /*let pathSegments = location.pathname.split('/').filter(Boolean); // 过滤掉空字符串，因为路径可能以'/'开始
    // 假设动态部分总是在第一个'/'之后，构建基础URL
    let baseUrl;
    if (pathSegments.length > 0) {
        // 包含动态部分
        baseUrl = location.protocol+'//'+location.host+'/'+pathSegments[0]+'/';
    } else {
        // 如果没有路径，只返回协议和主机
        baseUrl = location.protocol+'//'+location.host+'/';
    }*/
    

    location+="";
   var location_arr= location.split("modules/ldsoukebao/index.html");

    let url = location_arr[0] + 'axiosindex.php';

    // 合并额外的参数
    let _params = {...params, aaa: 'bbb'};
    url= cls_encryptyurl.Puyoung_Encryptyurlhavephp(url,_params);
    axios({
        method: 'post',
        url: url,
        data: _params,
        headers: { // 要设置的自定义请求头
            'Content-Type': 'application/json', // 设置请求体的内容类型
        }
    })
        .then(function (response) {
            if(response.data){
                callback(response.data);
            }
            else{
                callback(response);
            }

        })
        .catch(function (error) {
            console.error(error);
        });
}