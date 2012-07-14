/**
 * ExtendConfig:
 *  dispatch:String
 *  data:Array
 *  requestParams:Array 内部store请求数据所附带的参数
 */
Ext.define('Vmoss.lib.CCombo', {
    extend:'Ext.form.ComboBox',
    alias:'widget.ccombo',

    valueField:'id',
    displayField:'content',
    minChars:0,
    pageSize:10,

    initComponent:function () {
        Vmoss.Tool.log('CCombo running.');

        var me = this,
            options = {},
            instance = me.modelInstance;


//为存在ref的CCombo创建初始store
        if (me.ref) {
            me.data = [
                [
                    instance.get(me.ref),
                    instance.get(me.ori)
                ]
            ];
        }

        options.store = Ext.create('Vmoss.lib.CStore', {
            fields:[
                {name: me.valueField, mapping: 0},
                {name: me.displayField, mapping: 1}
            ],
            pageSize:me.pageSize,
            data: me.data,
            dispatch: me.dispatch,
            url: me.parent.bind.proxy.url
        });

        Ext.apply(me, options);

        this.callParent(arguments);
    },

// Combo不会主动将自身的limit传递给store(?)
    getParams:function(){
        var me = this,
            requestParams = {},
            params = me.callParent(arguments);

// 由Combo来传递额外的参数
        if (me.requestParams){
            Ext.each(me.requestParams, function(key){
                requestParams[key] = me.modelInstance.get(key);
            });
        }

// 考虑将pageSize传递到store
//        {
//            limit:me.pageSize
//        }

        return Ext.merge(requestParams, params)
    }
});