/**
 * ExtendConfig:
 *  dispatch:String
 *  data:Array
 *  requestParams:Array //内部store请求数据所附带的参数
 */
Ext.define('Vmoss.lib.CCombo', {
    extend:'Ext.form.ComboBox',
    alias:'widget.ccombo',

    enableKeyEvents:true,
    valueField:'id',
    displayField:'content',
    minChars:0,
    pageSize:10,

    forceSelection:true,
    selectOnFocus:true,
    editable:true,

    initComponent:function () {
        Vmoss.Tool.log('CCombo running.');

        var me = this,
            options,
            instance = me.modelInstance;

        if (me.association) {
// 此处分支为处理以关联构造的CCombo
            var associationUnit = me.parent.bind.associations.map[me.association];
            options = {
                valueField:'id',
                displayField:me.display,
                store:Ext.data.Store({
                    model:associationUnit.model,
                    pageSize:me.pageSize,
                    data:[]
                })
            };
        }
        else {
// 处理非关联型CCombo构造
// 为存在ref的CCombo创建初始临时store
            if (me.ref) {
                me.data = [
                    [
                        instance.get(me.ref),
                        instance.get(me.ori)
                    ]
                ];
            }

            options = {
                store:Ext.create('Vmoss.lib.CStore', {
                    fields:[
                        {name:me.valueField, mapping:0},
                        {name:me.displayField, mapping:1}
                    ],
                    pageSize:me.pageSize,
                    data:me.data,
                    dispatch:me.dispatch,
                    url:me.parent.bind.proxy.url
                })
            };
        }

        Ext.apply(me, options);

//全值清空认为是取消选择
        me.on({
            keyup:function () {
                if (me.getRawValue() === '') {
                    me.setValue(null);
                }
            }
        });

        me.callParent(arguments);
    },

// Combo不会主动将自身的limit传递给store(?)
    getParams:function () {
        var me = this,
            requestParams = {},
            params = me.callParent(arguments);

// 由Combo来传递额外的参数
        if (me.requestParams) {
            Ext.each(me.requestParams, function (key) {
                requestParams[key] = me.modelInstance.get(key);
            });
        }

// 考虑将pageSize传递到store
//        {
//            limit:me.pageSize
//        }

        return Ext.merge(requestParams, params)
    },

// 仅当setValue对象为Model时, 允许存在一个不处于store之内的Model对象被缓存, 该Model对象为Combo的默认显示值
    setValue:function (value) {
        if (value && value.isModel) {
            this.originalModelCache = value;
        }
        else if (this.originalModelCache && this.originalModelCache.get(this.valueField) === value) {
            arguments[0] = this.originalModelCache;
        }

        this.callParent(arguments);
    }
});