Ext.define('Vmoss.Tool', {
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
    requestLog: true,

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
    },

//返回一个仅复制原对象直接属性的对象
    copy:function(obj){
        return Ext.merge({}, obj);
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
    }()
});


Ext.Ajax.on({
// 此处处理服务器所捕获的逻辑异常
    beforerequest:function (conn, options) {
        if (Vmoss.Tool.requestLog){
            Vmoss.Tool.log([conn, 'Requesting']);
        }
    },
// 此处处理服务器所捕获的逻辑异常
    requestcomplete:function (conn, response, options) {
        var responseObj = Ext.JSON.decode(response);
        if (responseObj.success) return;
        Vmoss.Tool.promptBox(responseObj.exceptionType, responseObj.exceptionMessage);
    },
// 此处为默认的异常提示 404/500
    requestexception:function (conn, response, options) {
        Vmoss.Tool.promptBox('服务器连接异常', response.statusText);
    }
});
