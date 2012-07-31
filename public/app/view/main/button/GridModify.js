Ext.define('Vmoss.view.main.button.GridModify', {
    extend:'Ext.button.Button',

    text:'修改',
    iconCls:"icon-change",

//icon:Ext.MessageBox.ERROR
    handler:function () {
        var grid = this,
            selected = grid.selModel.getSelection();

        if (selected.length == 0) {
            Vmoss.Tool.promptBox('错误操作', '请选择!');
        } else if (selected.length > 1) {
            Vmoss.Tool.promptBox('错误操作', '请选择一个' +  grid.instanceLabel + '进行修改!');
        } else {
            Ext.create('Vmoss.view.main.ModifyView', {
                selInstance:selected[0],
                instanceLabel: grid.instanceLabel,
                modelField: (grid.featureList.modfiyFeature || grid.featureList.benchFeature)
            }).show();
        }
    },

// '修改'按钮构造
    initComponent:function () {
        this.tooltip = '修改选中的' + this.instanceLabel;
        this.callParent(arguments);
    }
});