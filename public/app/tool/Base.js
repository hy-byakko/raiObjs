Ext.define('Vmoss.Tool', {
    singleton:true,

    requires:[
        'Vmoss.lib.CForm',
        'Vmoss.lib.CCombo',
        'Vmoss.lib.CModel',
        'Vmoss.lib.CStore',
        'Vmoss.model.CurrentUser'
    ],

    logEnable:false,
    requestLog: true,

    functionMerge:function () {
// 将以参数形式传入的函数句柄转存为数组
        var fnc_list = [].slice.call(arguments, 0);
// 清理未定义的参数
        Ext.Array.unique(fnc_list);
        Ext.Array.remove(fnc_list, undefined);
        return function () {
            for (var i = 0, length = fnc_list.length; i < length; i++) {
// 实际参数转化为数组
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
    },

// 返回一个仅复制原对象直接属性的对象
    copy:function(obj){
        return Ext.merge({}, obj);
    },

// 添加一个方法确保当传入arguments时, arguments的第一个参数为一个可用对象({})
    insureArg:function(firstArg, args){
        if(!firstArg) {
            firstArg = {};
            args[0] = firstArg;
            args.length = 1;
        }
        return firstArg;
    },

    promptBox: function(){
        var msgCt;

        function createBox(t, s){
            return '<div class="message"><h3>' + t + '</h3><p>' + s + '</p></div>';
        }

        return function(title, format){
            if(!msgCt){
                msgCt = Ext.DomHelper.insertFirst(document.body, {id:'prompt-box-div'}, true);
            }
            var s = Ext.String.format.apply(String, Array.prototype.slice.call(arguments, 1));
            var m = Ext.DomHelper.append(msgCt, createBox(title, s), true);
            m.hide();
            m.slideIn('t').ghost("t", { delay: 1500, remove: true});
        };
    }(),

    csrfToken:function () {
        var result = {},
            metas = Ext.dom.Query.select('meta'),
            param,
            token;

        Ext.each(Ext.dom.Query.select('meta'), function (meta) {
            switch(meta.name){
                case 'csrf-param':
                    param = meta.content;
                    break;
                case 'csrf-token':
                    token = meta.content;
                    break;
            }
        });

        result[param] = token;
        return result;
    }()
});

Ext.Ajax.on({
// 记录本程序向服务器发起的所有请求
    beforerequest:function (conn, options) {
        if (Vmoss.Tool.requestLog){
            Vmoss.Tool.log([conn, 'Requesting']);
        }
        if(options.method !== 'GET'){
            options.params = options.params || {};
            Ext.mergeIf(options.params, Vmoss.Tool.csrfToken);
        }
    },
// 此处处理服务器所捕获的逻辑异常
    requestcomplete:function (conn, response, options) {
        var operation = options.operation,
            responseObj = Ext.JSON.decode(response.responseText);
        if (responseObj.success) return;
// 默认行为将会丢弃返回数据, 此处以response属性来存储
        Ext.apply(operation, {
            response: response
        });
        Vmoss.Tool.promptBox(responseObj.exceptionType, responseObj.exceptionMessage);
    },
// 此处为默认的异常提示 404/500
    requestexception:function (conn, response, options) {
        Vmoss.Tool.promptBox('服务器异常', response.statusText);
    }
});
