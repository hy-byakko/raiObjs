Ext.define('Vmoss.tool.Base', {
    singleton:true,

    requires:[
        'Vmoss.tool.Request',
        'Vmoss.lib.CForm',
        'Vmoss.lib.CCombo',
        'Vmoss.lib.CModel',
        'Vmoss.lib.CStore',
        'Vmoss.model.CurrentUser'
    ],

    logEnable:false,

    function_merge:function () {
        var fnc_list = [].slice.call(arguments, 0);
        return function () {
            for (var i = 0, length = fnc_list.length; i < length; i++) {
                var params = [].slice.call(arguments, 0);
                fnc_list[i].apply(this, params)
            }
        }
    },

    log:function (obj) {
        if (this.logEnable) {
            console.log(obj);
        }
    },

//比较两个对象是否含有相同的值, 第三个参数为迭代器. 当遇到与迭代器内相同的属性时, 会对该属性的值作迭代比较, 而迭代器属性对应的值则作为下一层比较的迭代器
    eqlObject:function (obj, anotherObj, iterate) {
        if (Ext.Object.getSize(obj) != Ext.Object.getSize(anotherObj)) {
            return false;
        }
        var warden = true;
        iterate = iterate || {};
        for (var attr in obj) {
            if (obj[attr] != anotherObj[attr]) {
                if (!(iterate[attr] && this.eqlObject(obj[attr], anotherObj[attr], iterate[attr]))) {
                    warden = false;
                    break;
                }
            }
        }
        return warden
    },

//将游离在对象上的feature数组收集到一个Object上
    featureCollect:function (object, config) {
        config = config || {};
        var collection = object.featureList || {},
            lunchScan = config.scan || false,
            featureKeys = [
                'add', 'modify', 'bench', 'search', 'grid'
            ];

        if (lunchScan) {
            Ext.Array.each(featureKeys, function (featureKey) {
                if (object[featureKey + 'Feature']) {
                    collection[featureKey + 'Feature'] = Ext.merge(object[featureKey + 'Feature'], collection[featureKey + 'Feature']);
                }
            });
        }

        return collection;
    },

    errorMessage:function (message, config) {
        Ext.Msg.show({
            title:'错误信息',
            msg:message,
            buttons:Ext.MessageBox.OK,
            icon:Ext.MessageBox.ERROR
        });
    }
})