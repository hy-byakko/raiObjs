Ext.define('Vmoss.lib.CModel', {
    extend:'Ext.data.Model',

    constructor:function () {
        Vmoss.tool.Base.log('CModel running.');

        var me = this;

        me.addEvents({
            afterset:true,
            response:true
        });

//所有的CModel默认reader在此设置.
        if (me.proxy) {
            me.proxy.setReader({
                root:'root',
                totalProperty:'totalLength'
            });
        }

        me.callParent(arguments);
    },

//获得feature的存储空间
    getFeatureList:function (feature) {
        if (Ext.typeOf(feature) !== 'string') {
            return;
        }
        return this[feature + 'Feature'];
//        feature.substring(0,1).toUpperCase() + feature.substring(1);
    },

//获得指定feature键名
    getFeatureKeys:function (feature) {
        var list = this.getFeatureList(feature),
            result = [];
        if (!list) {
            return;
        }
        for (var i = 0, length = list.length; i < length; i++) {
            result.push(list[i].field);
        }
        return result;
    },

//返回该field的fieldExtend对象.
    getFieldsExtend:function (field) {
        return this._getListExtend(field, this['fieldsExtend']);
    },

//返回指定feature的fieldExtend对象(默认的fieldsExtend与feature内额外属性进行merge).
    getFeatureExtend:function (field, feature) {
        return Ext.Object.merge(this._getListExtend(field, this['fieldsExtend']), this._getListExtend(field, this.getFeatureList(feature)));
    },

//返回指定list内的fieldExtend对象.
    _getListExtend:function (field, list) {
        if (!list) {
            return;
        }
        for (var i = 0, length = list.length; i < length; i++) {
            if (field == list[i].field) {
                return list[i];
            }
        }
    },

    set:function (fieldName, newValue) {
        this.callParent(arguments);
        this.fireEvent('afterset', this, fieldName);
    },

    save:function (options) {
        options = (options || {});
        var me = this;

        if (options.fireResponse) {
            Vmoss.tool.Base.function_merge(options.callback, function (options, success, response) {
                me.fireEvent('response', me, response);
            });
            options.fireResponse = true;
        }

        this.callParent(options);
    },

//
    bindForm:function (bindForm) {
        this.bindForms = this.bindForms || [];
        this.bindForms.push(bindForm);

        if (!this.bindForms) {
            this.on("response", this.componentBindHandle);
        }
    },

//此方法为model实例内的某一属性与component的某一属性绑定的实现, 绑定为双向相互都能修改对方的值.
    bindProperty:function (options) {
        options = options || {};
        if (options.component && options.component.isComponent) {
            var modelBind = {
                bind:this,
                field:options.field,
                handle:options.handle
            };

            if (!options.component.bindItems) {
                options.component.on("blur", this.componentBindHandle);
            }
            this._bind(options.component, modelBind);

            var componentBind = {
                bind:options.component,
                field:options.field,
                handle:options.handle
            };

            if (!this.bindItems) {
                this.on("afterset", this.modelBindHandle);
            }
            this._bind(this, componentBind);

            this.fireEvent('afterset', this, options.field);
        }
    },

    _bind:function (item, bindItem) {
        if (!this.bindExist(item, bindItem)) {
            item.bindItems = item.bindItems || [];
            item.bindItems.push(bindItem)
        }
    },

    bindExist:function (obj, bindItem) {
        if (!obj.bindItems) {
            return false
        }
        Ext.each(obj.bindItems, function (item) {
            if (Vmoss.tool.Base.eqlObject(item, bindItem, {
                handle:{}
            })) {
                return true;
            }
        });
        return false;
    },

    componentBindHandle:function (component) {
        Ext.Array.each(component.bindItems, function (bindItem) {
            var model = bindItem.bind,
                componentValue;
            componentValue = model.getValue(component, bindItem.handle.get);
            if (componentValue != model.get(bindItem.field)) {
                model.set(bindItem.field, componentValue)
            }
        })
    },

    modelBindHandle:function (model, field) {
        Ext.Array.each(model.bindItems, function (bindItem) {
            var component = bindItem.bind,
                componentValue;
            componentValue = model._getValue(component, bindItem.handle.get);
            if (field == bindItem.field && componentValue != model.get(bindItem.field)) {
                model._setValue(component, bindItem.handle.set, model.get(bindItem.field));
            }
        })
    },

//This function for get a value from a instance with an attr or method.
    _getValue:function (item, method) {
        if (typeof(method) == 'function') {
            return method.call(item);
        } else {
            return item[method];
        }
    },

//This function for set a value from a instance with an attr or method.
    _setValue:function (item, method, newValue) {
        if (typeof(method) == 'function') {
            method.call(item, newValue);
        } else {
            item[method] = newValue;
        }
    }
});