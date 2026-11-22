<!doctype html>
<html lang="zh">
<head>
    <meta charset="UTF-8">
    <meta name="viewport"
        content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>展会产品信息</title>
    <link rel="stylesheet" href="{$CRMCOMMONURL}crmcommon/js/element/element-plus-2.3.9.css" type="text/css" />
    <link rel="stylesheet" href="{$CSSURL}themes/softed/element-plus-common.css" type="text/css" />
</head>
<style>
    a {
        color: #3B7CFF;
        text-decoration:none;
    }
    .el-table .cell a {
        display: block;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
    }
    .yaadee-search {
        padding: 20px 5px;
    }
    .yaadee-search-content{
        display: flex;
    }
    .yaadee-search-content-field {
        flex: 1;
        display: flex;
        padding-left: 5px;
    }
    .yaadee-search-content-field div:first-child {
        padding-right: 20px;
    }
    .txtYaadeeSearch {
        border: 1px solid #dbdbdb;
        width: 90%;
        background-color: #ffffff;
        height: 25px;
        line-height: 25px;
        border-radius: 4px;
        padding: 0 8px;
    }
    .txtYaadeeSearch:focus {
        border: 1px solid #dbdbdb;
    }
    .yaadee-search-btn {
        width: 200px;
        display: flex;
        padding-top: 20px;
        margin: 0 auto;
    }
    .yaadee-search-btn div{
        background-color: #3b7cff;
        text-align: center;
        width: 60px;
        height: 30px;
        line-height: 30px;
        border-radius: 3px;
        border: 1px solid #3b7cff;
        color: #fff;
        cursor: pointer;
        margin: 0 auto;
    }
    .yaadee-search-btn div:hover{
        border: 1px solid #1c61da;
        background-color: #1c61da;
    }
</style>

<body style="overflow: hidden;">
    <div id="app">
        <div class="yaadee-search">
            <div class="yaadee-search-content">
                <div class="yaadee-search-content-field">
                    <div>展会名称</div>
                    <div>
                        <input type="text" class="txtYaadeeSearch" name="campaignname" id="campaignname" v-model="campaignname">
                    </div>
                </div>
                <div class="yaadee-search-content-field">
                    <div>展台名称</div>
                    <div>
                        <input type="text" class="txtYaadeeSearch" name="potentialname" id="potentialname" v-model="potentialname">
                    </div>
                </div>
                <div class="yaadee-search-content-field">
                    <div>展位号</div>
                    <div>
                        <input type="text" class="txtYaadeeSearch" name="zhanwei_no" id="zhanwei_no" v-model="zhanwei_no">
                    </div>
                </div>
            </div>
            <div class="yaadee-search-btn">
                <div id="search" @click="search">查询</div>
                <div id="exprot" @click="exprot">导出</div>
            </div>
        </div>
        {literal}
        <el-container class="container-table" v-if="tableData.length > 0">
            <el-table :style="{ height: contentTableHeight + 'px' }" :data="tableData" border style=" width: 100%;padding: 0 10px;" stripe scrollbar-always-on empty-text="暂无数据" :header-cell-style="{ background:'#ecf5ff',maxheight:'10px',color:'#000000', }">
                <el-table-column v-for="(header, index) in headData" :key="index" width="120px" align="center" :fixed=isfixed(index) >
                    <template #header>
                        <div v-html="header"></div>
                    </template>
                    <template #default="scope">
                        <div v-html="scope.row[index]"></div>
                    </template>
                </el-table-column>
            </el-table>
            <el-footer class="footer-container">
                <template v-if="tableData.length > 0">
                    <span class="custom-total">共 {{total}} 条</span>
                </template>
                <!-- <el-pagination background 
                    @size-change="handleSizeChange"
                    v-model:current-page="currentPage"
                    :page-size="20"
                    :total="total"
                    layout="prev, pager, next">
                </el-pagination> -->
            </el-footer>
        </el-container>
        {/literal}
    </div>
</body>

<script type="text/javascript" src="{$CRMCOMMONURL}crmcommon/js/jquery/jquery.min.js"></script>
<script type="text/javascript" src="{$CRMCOMMONURL}crmcommon/js/element/vue-3.2.36.js"></script>
<script type="text/javascript" src="{$CRMCOMMONURL}crmcommon/js/element/element-plus-2.3.9.js"></script>
<script>
    const App = {
        data() {
            return {
                headData: [],
                contentTableHeight: window.innerHeight - 119 - 60,
                currentPage: 2,
                total: 0,
                tableData: [],
                campaignname:'',
                potentialname: '',
                zhanwei_no: ''
            }  
        },
        mounted() {
            this.search();
        },
        methods: {
            isfixed(index) {
                if (index < 7) {
                    return true;
                }
            },
            search() {
                let that = this;
                var campaignname = that.campaignname;
                var potentialname = that.potentialname;
                var zhanwei_no = that.zhanwei_no;
                $.ajax({
                    url: 'index.php?module=ReportAnalysis&action=ReportAnalysisAjax&file=yeedaa&mode=search&campaignname=' + encodeURIComponent(campaignname) + '&potentialname=' + encodeURIComponent(potentialname) + '&zhanwei_no=' + encodeURIComponent(zhanwei_no),
                    data: '',
                    type: 'POST',
                    dataType: 'json',
                    async: false,
                    timeout: 50000,
                    success: function (data) {
                        if(data.code == 1){
                            if(data.result.list.length > 0){
                                that.headData = data.result.line_header;
                                that.tableData = data.result.list;
                                that.total = data.result.list.length;
                                // $('.custom-total').html('共 '+ data.result.list.length +' 条');
                            }
                            else{
                                that.tableData = [];
                                that.headData = [];
                            }
                        }
                    }
                });
            },
            // pageSize 改变时会触发  
            handleSizeChange(val) {
                console.log(val);
            },
            exprot() {
                let that = this;
                var campaignname = that.campaignname;
                var potentialname = that.potentialname;
                var zhanwei_no = that.zhanwei_no;

                var url = 'index.php?module=ReportAnalysis&action=ReportAnalysisAjax&file=yeedaa&mode=export&campaignname=' + encodeURIComponent(campaignname) + '&potentialname=' + encodeURIComponent(potentialname) + '&zhanwei_no=' + encodeURIComponent(zhanwei_no);
                // window.open(url, '_blank');//会闪动一下

                window.location.href = url;

            }
        }
    }
    const app = Vue.createApp(App);
    app.use(ElementPlus);
    app.mount("#app");
</script>
</html>