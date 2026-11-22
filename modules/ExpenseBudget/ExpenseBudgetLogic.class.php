<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @author zxm 2020-06-03
 * 费用预算特殊按钮
 */
class ExpenseBudgetLogic extends BaseLogic {
    //列表页的【更多】按钮、新建按钮
	public function getListMoreBtn() {
		parent::getListMoreBtn();
        $createBtn = array();
        //直接录入预算
        $createBtn['basicBudget']['label'] = getFixedLabel('basicBudget');
        $createBtn['basicBudget']['permit'] = 'yes';
        $createBtn['basicBudget']['btnkey'] = 'basicBudget';
        //按销售目标预算 -- 销售目标模块未开启 则不显示
        if(vtlib_isModuleActive("SalesGoal")){
            $createBtn['salesGoalBudget']['label'] = getFixedLabel('salesGoalBudget');
            $createBtn['salesGoalBudget']['permit'] = 'yes';
            $createBtn['salesGoalBudget']['btnkey'] = 'salesGoalBudget';
        }
        //按销售业绩预算
        $createBtn['salesAchievementBudget']['label'] = getFixedLabel('salesAchievementBudget');
        $createBtn['salesAchievementBudget']['permit'] = 'yes';
        $createBtn['salesAchievementBudget']['btnkey'] = 'salesAchievementBudget';
        $this->list_buttons['Create']['list'] = $createBtn;
        //更多按钮-增加按钮【重算预算金额】
        $btn['reCalculationBudget']['label'] = getFixedLabel('reCalculationBudget');
        $btn['reCalculationBudget']['permit'] = 'yes';
        $this->list_buttons['More']['list'] = f_array_insert($this->list_buttons['More']['list'],$btn,5);
        $this->list_buttons['More']['permit'] = 'yes';
	}
    //详情页的【更多】按钮-增加【重算预算金额】
    public function getDetailMoreBtn() {
        parent::getDetailMoreBtn();
        //更多按钮-增加按钮【重算预算金额】
        $btn['reCalculationBudget']['label'] = getFixedLabel('reCalculationBudget');
        $btn['reCalculationBudget']['permit'] = 'yes';
        $this->detail_buttons['More']['list'] = f_array_insert($this->detail_buttons['More']['list'],$btn,5);
        $this->detail_buttons['More']['permit'] = 'yes';
    }
}
