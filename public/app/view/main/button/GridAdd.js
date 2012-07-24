Ext.define('Vmoss.view.main.button.GridAdd', {
    extend: 'Ext.button.Button',

    text:'添加',
    iconCls:"icon-add",

// 此处的域为grid
    handler:function () {
        var grid = this;

        Ext.create('Vmoss.view.main.AddView', {
            model:grid.model,
            grid:grid,
            instanceLabel: grid.instanceLabel,
            modelField: (grid.featureList.addFeature || grid.featureList.benchFeature)
        }).show();
    },

// '添加'按钮构造
    initComponent:function () {
        this.tooltip = '添加新的' + this.instanceLabel;
        this.callParent(arguments);
    }
});