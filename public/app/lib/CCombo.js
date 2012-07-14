Ext.define('Vmoss.lib.CCombo', {
    extend:'Ext.form.ComboBox',
    alias:'widget.ccombo',

    valueField:'id',
    displayField:'content',
    minChars:0,
    pageSize:10,

    initComponent:function () {
        Vmoss.tool.Base.log('CCombo running.');

        var me = this,
            options = {};

        options.store = Ext.create('Vmoss.lib.CStore', {
            fields:[
                {name: me.valueField, mapping: 0},
                {name: me.displayField, mapping: 1}
            ],
            dispatch: me.dispatch,
            url: me.parent.bind.proxy.url
        });

        Ext.apply(me, options);

        this.callParent(arguments);
    },

// Combo不会主动将自身的limit传递给store(?), bug修正(?)
    getParams:function(){
        var me = this,
            params = me.callParent(arguments);

        return Ext.merge({
            limit:me.pageSize
        }, params)
    }
});