/**
 * ExtendConfig:
 *  bind: Model         //绑定一个model的实例, 并以该model实例创建自身field
 *  modelField: Array   //如果指定的情况会依照此数组内的属性创建field, 并且添加model内相应的额外属性
 *  feature: String     //指定的情况下会额外遍历model内(例: 'grid' + 'Feature')属性, 添加到field创建
 */
//Todo 绑定可能会造成无法进行垃圾回收, 注意释放内存, 以免造成泄漏
Ext.define('Vmoss.lib.CForm', {
    extend:'Ext.form.Panel',

    initComponent:function () {
        Vmoss.tool.Base.log('CForm running.');
        var me = this;

        //添加vtype——password,验证修改密码与确认密码要一致
        Ext.apply(Ext.form.field.VTypes, {
            password: function(val, field) {
                if (field.initialPassField) {
                    var pwd = field.up('form').down('#' + field.initialPassField);
                    return (val == pwd.getValue());
                }
                return false;
            },
            passwordText: '修改密码与确认密码不一致！'
        });

        if (me.bind && me.bind.isModel) {
            this.bindModel(me.bind)
        }

        this.callParent(arguments);
    },

    bindModel:function(instance){
        var me = this,
            options = {},
            fieldList;

        options.items = me.items || [];
        options.defaultType = 'textfield';

        fieldList = (me.modelField || instance.getFeatureList(me.feature) || instance.fields.keys);
        Ext.Array.each(fieldList, function (field) {
                options.items.push(me.getModelField({
                    instance: instance,
                    field: field,
                    feature: me.feature
                }));
// 处理存在参照的情况
                Ext.Array.each(options.items, function(item){

                });
            }
        );

        Ext.apply(me, options);

        me.on('afterrender', function(){
            me.loadRecord(me.bind);
        });
    },

    modelUpdate:function () {
        if (this.getForm().isValid()) {
            this.getForm().updateRecord(this.bind);
        }
    },

    getModelField:function (options) {
        options = options || {};
        var instance = options.instance,
            field = options.field,
            feature = options.feature,
            fieldKey = (Ext.typeOf(field) == 'string') ? field : (field.name || field.field),
            config = instance.getFeatureExtend(fieldKey, feature),
            item = {};

        if(Ext.typeOf(field) !== 'string') {
            config = Ext.Object.mergeIf(field, config);
        }
        if (config) {
            for (var attr in config) {
                switch (attr) {
                    case 'field':
                        item.name = config[attr];
                        break
                    case 'label':
                        item.fieldLabel = config[attr];
                        break
                    default:
                        item[attr] = config[attr];
                }
            }
        }
        else {
            item = {
                fieldLabel:fieldKey,
                name:fieldKey
            };
        }

        Ext.Object.mergeIf(item, {
            parent: this,
            listeners:{
                blur: this.modelUpdate,
                scope: this
            }
        });

        return item;
    }
});