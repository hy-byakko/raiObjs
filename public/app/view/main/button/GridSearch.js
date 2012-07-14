Ext.define('Vmoss.view.main.button.GridSearch', {
    extend:'Ext.button.Button',

    text:'检索',
    iconCls:"icon-search",

    handler:function () {
                        var store = grid.store;
                        store = setCondition(store);
                        store.reload();
                    },

// '检索'按钮构造
    initComponent:function () {
        this.tooltip = '检索符合检索条件的' + this.instanceLabel;
        this.callParent(arguments);
    }
});