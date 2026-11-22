<!--中间-->

<div id="container_salesGoalChart" style='width:100%;height:600px;padding-left:-5px;float:left'></div>
<script>
        highChartValue = {$highChartValue};//BUG0076992 lius 20231218 VM6734:1 Uncaught SyntaxError: Identifier 'highChartValue' has already been declared。 （备注：搞不懂为啥会报错,先去掉修饰符）
        {literal}
        //newHighChart('container_salesGoalChart',highChartValue)
        {/literal}
</script>