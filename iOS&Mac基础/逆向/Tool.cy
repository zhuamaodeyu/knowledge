(function(exports) {

    // 全局函数 
    function test() {

    };

    // 局部，需要通过 import tool , too.test()形式访问
    exports.test = function() {

    };


}(exports);



// 使用  
// @import Tool 