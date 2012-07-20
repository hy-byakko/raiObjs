/**
 * CForm的基础定位为Model提供一种UI显示, 即它会呈现出为他所绑定的model的表单特性, 并附加modelField所提供的额外属性
 *      会在fireUpdate的时机更新所绑定的model
 *      可激发所绑定的model于远程交互, 行为类似于表单的提交
 *      仅在model与远程交互之后才会与所绑定的model进行数据同步, 并不时时随model的改变所改变
 *      在自身销毁前会取消与model的绑定
 *      只会与一个model发生绑定关系
 *
 * ExtendConfig:
 *  bind: Model         //绑定一个model的实例, 并以该model实例创建自身field
 *  modelField: Array   //如果指定的情况会依照此数组内的属性创建field, 并且添加model内相应的额外属性
 *  feature: String     //指定的情况下会额外遍历model内(例: 'grid' + 'Feature')属性, 添加到field创建
 *  fireUpdate: String  //该事件触发时更新对象, 默认为beforeaction
 */
Ext.define('Vmoss.lib.CForm', {
    extend:'Ext.form.Panel',

    initComponent:function () {
        Vmoss.Tool.log('CForm running.');
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

// 在model的form绑定中添加自身
        me.bind.bindForm(me);

        options.items = me.items || [];
        options.defaultType = 'textfield';

        fieldList = (me.modelField || instance.getFeatureList(me.feature) || instance.fields.keys);
        Ext.Array.each(fieldList, function (field) {
                options.items.push(me.getModelField({
                    instance: instance,
                    field: field,
                    feature: me.feature
                }));
            }
        );

        Ext.apply(me, options);

        me.on({
            afterrender: function(){
                me.loadRecord(me.bind);
            },
// 在销毁前释放与model实例的链接
            beforedestroy: function(){
                me.bind.unBindForm(me);
                delete me.bind;
            }
        });
    },

    modelUpdate:function () {
        if (this.getForm().isValid()) {
            this.getForm().updateRecord(this.bind);
        }
    },

//以所绑定的实例为基础创建相应的field
    getModelField:function (options) {
        options = options || {};
        var me = this,
            instance = options.instance,
            field = options.field,
            feature = options.feature,
            fieldKey = (Ext.typeOf(field) == 'string') ? field : (field.name || field.field),
            config = Vmoss.Tool.copy(instance.getFeatureExtend(fieldKey, feature)),
            item = {},
            listener = {
                scope:me
            },
            event = me.fireUpdate || 'beforeaction';

//备份CForm自身所提供的modelField属性, 并使之与model内的属性合并
        if (Ext.typeOf(field) !== 'string') {
            config = Ext.mergeIf(Vmoss.Tool.copy(field), config);
        }

//为config添加创建他的实例链接
        config = Ext.mergeIf(config, {
            modelInstance: instance
        });

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

        listener[event] = this.modelUpdate;

        Ext.Object.mergeIf(item, {
            parent: this,
            listeners: listener
        });

        return item;
    }
});